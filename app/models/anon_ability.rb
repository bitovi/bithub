class AnonAbility
  include CanCan::Ability

  def initialize(user=nil)
    can :read, Entity
    can :read, Plan
    can :read, Tag
    can :read, User
  end
end
