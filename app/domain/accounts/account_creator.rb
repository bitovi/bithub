module Accounts
  class AccountCreator

    def initialize(ident)
      @identity = ident
      @fdc = FakeDigestsCreator.new(@identity)
    end

    def create
      create_user
      after_process
    end

    def after_process
      @user.award_points_for_linking(@identity.provider)
      @fdc.create_missing_repos_and_stars

      @user.async_collect_authored_entities
      @user.async_reward_if_eligible
      @user.reload
    end

    def create_user
      @user = @identity.create_user({
        name: @identity.name,
        email: @identity.email
      })
    end
    
    # def build
    #   build_user
    #   after_process
    # end
    
    # def build_user
    #   @user = @identity.build_user({
    #     name: @identity.name,
    #     email: @identity.email
    #   })
    # end

  end
end
