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
      can :destroy_upvote, Upvote
      cannot :create_award, Award
      cannot :read, Achievement
    end

    can :destroy_user, User do |subject_user|
      user.has_role?(:admin) || user.id == subject_user.id 
    end 

  end
end
