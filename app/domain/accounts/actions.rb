module Accounts
  class Actions

    def initialize(user, identity, other_user = nil)
      @current_user = user
      @identity = identity
      @other_user = other_user
    end

    def async_collect_and_reward
      @current_user.async_collect_authored_entities
      @current_user.async_update_total_score
      @current_user.async_reward_if_eligible
      self
    end

    def async_snatch
      if @other_user
        Users::ActivitiesAndEntitiesSnatcher.new(@current_user, @other_user).async_execute
      end
      self
    end

    def async_create_fake_digests
      Accounts::FakeDigestsCreator.new(@identity).async_execute
      self
    end

  end
end
