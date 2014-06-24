class UserAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Tag
    can :read, Country
    can :read, Reward
    can [:read, :update], User, id: user.id
    can [:create, :read], Entity
    can [:update, :destroy], Entity # check current_user entities
    can :create_upvote, Upvote
    can :destroy_upvote, Upvote
    can :read_pagination, Pagination
    can :read, Achievement
  end
end
