class AnonAbility
  include CanCan::Ability

  def initialize(user=nil)
    can :read, Entity
    can :read, Tag
    can :read, Reward
    can :read, Users
    can :read_pagination, Pagination
  end
end
