class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, :all
      can :add_role, :user
      can :remove_role, :user
      can :read_sensitive_data, :user
    else
      can :read, :all
    end
  end
end
