module Accounts
  class AccountCreator

    def initialize(ident)
      @identity = ident
      @fdc = FakeDigestsCreator.new(@identity)
    end

    def build_account
      @user = identity.build_user({
        name: @identity.name,
        email: @identity.email
      })

      @user.award_points_for_linking(@identity.provider)
      @fdc.create_missing_repos_and_stars

      @user.async_collect_authored_entities
      @user.async_reward_if_eligible
      @user
    end

  end
end
