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
      return unless @current_user.save

      @fdc.create_missing_repos_and_stars
      @current_user.calculate_avatar_url
      @current_user.award_points_for_linking(@identity)
      @current_user.save

      Accounts::Actions
      .new(@current_user, @identity)
      .async_create_fake_digests
      .async_collect_and_reward

      @current_user
    end

  end
end
