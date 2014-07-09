class AnonAbility
  include CanCan::Ability

  def initialize(user=nil)
    can :read, Entity
    can :read, Tag
    can :read, Reward
    can :read, User
    can :read, Funnel
    can :read_pagination, Pagination
  end
end
