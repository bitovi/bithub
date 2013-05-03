class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :access_admin_stuff
      can :manage, :all
    else
      cannot :access_admin_stuff
      can :read, :all
    end
  end
end
