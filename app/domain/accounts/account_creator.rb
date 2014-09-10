module Accounts
  class AccountCreator

    def initialize(ident)
      @identity = ident
    end

    def create
      @current_user = User.new({
        name: @identity.name,
        email: @identity.email
      })

      @current_user.identities << @identity
      return unless @current_user.save && @identity.save

      @current_user.calculate_avatar_url
      @current_user.award_points_for_linking(@identity)
      @current_user.save

      Accounts::Actions
      .new(@current_user, @identity)
      .async_collect_and_reward

      @current_user
    end

  end
end
