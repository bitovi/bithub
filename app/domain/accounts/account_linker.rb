module Accounts
  class AccountLinker

    def initialize(user, ident)
      @current_user = user
      @identity = ident
      @state = :undecided
      @offending_identities = []
    end

    # --- State checking
    
    def determine_state
      if @current_user.andand.identities.andand.include?(@identity)
        @state = :already_linked
      elsif identity_free?
        @state = :only_linking
      elsif not(identities_clash?)
        @state = :valid_merge
      else
        @state = :invalid_merge
      end
      self
    end

    def link
      return nil if (@state == :undecided) || (@state == :already_linked)
      if only_linking?
        @current_user.identities << @identity
        after_link_process
      elsif merging?
        @other_user = @identity.user
        @current_user.identities += @identity.user.identities
        async_snatch
        after_link_process
      else
        nil
      end
    end

    def after_link_process
      @current_user.calculate_avatar_url
      @current_user.award_points_for_linking(@identity)
      @current_user.update_blank_attrs(@identity)
      @fdc = Accounts::FakeDigestsCreator.new(@identity).execute

      async_collect_and_reward

      @current_user.save
    end

    def unlink
      if user_is_owner? && user_has_more_than_one?
        Users::EntitiesUnlinker.new(@identity).async_unlink
        @identity.destroy
      else
        nil
      end
    end

    # --- State determination

    def identity_free?
      @identity.user.nil?
    end

    def identities_clash?
      @identity.user.identities.present? && providers_of_same_type
    end

    def providers_of_same_type
      @identity.user.identities.reduce(false) { |acc, i| acc || current_user_has_provider?(i.provider) }
    end

    def current_user_has_provider?(provider)
      @current_user.andand.identities.andand.map {|i| i.provider}.andand.include?(provider)
    end

    # --- Async actions
    
    def async_snatch
      Users::ActivitiesAndEntitiesSnatcher.new(@current_user, @other_user).async_execute
    end

    def async_collect_and_reward
      @current_user.async_collect_authored_entities
      @current_user.async_update_total_score
      @current_user.async_reward_if_eligible
    end

    # --- Public API

    def not_merging?
      @state == :only_linking
    end

    def valid_merge?
      @state == :valid_merge
    end

    def invalid_merge?
      @state == :invalid_merge
    end
    
    def merging_state
      @state
    end

    def merging_user
      @identity.user
    end

    def offending_identities
      if @identity.andand.user.andand.identities.present?
        @identity.user.identities.select { |i| current_users_identity_providers.include?(i.provider) }
      end
    end

    alias_method :only_linking?, :not_merging?
    alias_method :merging?, :valid_merge?

    private
    def user_is_owner?
      @current_user.identities.include?(@identity)
    end

    def user_has_more_than_one?
      @current_user.identities.andand.size > 1
    end

    def current_users_identity_providers
      @current_user.andand.identities.andand.map do |i|
        i.provider
      end || []
    end

  end
end
