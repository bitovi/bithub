class AccountCreator

  def initialize(i, ud)
    @identity = i
    @user_data = ud
    @fdc = FakeDigestsCreator.new(@identity, @user_data)
  end

  def create
    @user = identity.build_user({
      name: @user_data.name,
      email: @user_data.email
    })
    @user.award_points_for_linking(@identity.provider)
    @user.save!

    @fdc.create_missing_repos_and_stars

    @user.async_collect_authored_entities
    @user.async_reward_if_eligible
    @user
  end

end
