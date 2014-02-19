module Accounts
  class AccountCreator

    def initialize(ident)
      @identity = ident
      @fdc = FakeDigestsCreator.new(@identity)
    end

    def create
      @current_user = User.new({
        name: @identity.name,
        email: @identity.email
      })

      @current_user.identities << @identity
      @current_user.save

      @fdc.create_missing_repos_and_stars
      @current_user.calculate_avatar_url
      @current_user.award_points_for_linking(@identity)
      @current_user.save

      async_collect_and_reward
      @current_user
    end
    
    def async_collect_and_reward
      @current_user.async_collect_authored_entities
      @current_user.async_update_total_score
      @current_user.async_reward_if_eligible
    end

  end
end
