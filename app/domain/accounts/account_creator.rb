module Accounts
  class AccountCreator

    def initialize(ident)
      @identity = ident
      @fdc = FakeDigestsCreator.new(@identity)
    end

    def create
      @user = User.new({
        name: @identity.name,
        email: @identity.email
      })

      @user.identities << @identity

      @fdc.create_missing_repos_and_stars
      @user.award_points_for_linking(@identity.provider)

      @user.async_collect_authored_entities
      @user.async_reward_if_eligible
      @user.save!
      @user
    end

  end
end
