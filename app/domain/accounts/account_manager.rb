module Accounts
  class AccountManager
    attr_reader :current_user, :identity

    def initialize(current_user = nil)
      @current_user = current_user
    end

    def find_or_create_user(provider, oauth_data)
      name, email = self.class.pluck_data_for(provider, oauth_data)
      @identity = Identity.find_or_create_with_oauth_data(oauth_data)
      user = nil

      begin
        if current_user_exists?
          user = update_and_merge(name, email)
        elsif identity.has_assigned_user?
          user = identity.user
        else
          user = create_and_collect(name, email)
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error e.message
      end
      user
    end

    def create_and_collect(name, email)
      user = identity.build_user({name: name, email: email})
      ActiveRecord::Base.transaction do
        identity.user.award_points_for_linking(identity.provider)
        identity.save!
      end

      self.delay.create_missing_repos_and_watches!
      identity.reload.user.collect_authored_entities.reward_if_eligible
      user
    end

    def update_and_merge(name, email)
      ActiveRecord::Base.transaction do
        current_user.update_blank_oauth_attrs!({name: name, email: email})
        current_user.award_points_for_linking(identity.provider)
        current_user.link_ident!(identity)
        current_user.reload.collect_authored_entities.reward_if_eligible
      end

      self.delay.create_missing_repos_and_watches!
      current_user
    end

    def create_missing_repos_and_stars!
      if identity.provider == 'twitter'
        create_internal_follows!
      elsif identity.provider == 'github'
        create_internal_stars!
      end
    end

    def create_internal_follows!
      ApiCache.where(provider: 'twitter', uid: @identity.uid).each do |res|
        Dispatcher.new(Events::Twitter::CustomFollow.new(res.name, @identity)).dispatch
      end
    end
    
    def create_internal_stars!
      ApiCache.where(provider: 'github', uid: @identity.uid).each do |res|
        Dispatcher.new(Events::Github::CustomWatch.new(res.name, @identity)).dispatch
      end
    end

    def current_user_exists?
      current_user != nil
    end

    def self.pluck_data_for(provider, oauth_data)
      case provider
      when "github"
        name = name_from(oauth_data)
        email = email_from(oauth_data)
      when "twitter"
        name = name_from(oauth_data)
      when "meetup"
        name = name_from(oauth_data)
      else
        raise "Provider #{provider} not handled"
      end
      [name, email]
    end

    def self.name_from(oauth_data)
      oauth_data['info']['name']
    end

    def self.email_from(oauth_data)
      oauth_data['info']['email']
    end
  end
end
