class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, :all
      can :create_award, Award
      can :manage_roles, User
      can :read_sensitive_data, :user
    else
      can :read, :all
      can :create_upvote, Upvote
      can :create_anteup, Anteup
      cannot :create_award, Award
      cannot :read, Achievement
    end
  end
end
