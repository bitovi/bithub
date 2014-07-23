class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if account.has_role? :admin
      can :manage, :all
    else
      can [:read, :read_tags_tree], Tag
      can [:read, :update], Brand, id: account.brand.id
      can :read, Country
      can [:read, :update], ScoringRule
      can :manage, Reward
      can :manage, Achievement
      can :manage, FeedConfig, brand_id: account.brand.id
      can :manage, Funnel
      can :read, User # check somehow if user is present in current tenant
      can :manage_roles_on_user, User
      can :manage, Entity
      can :create_award, Award
      can :read_pagination, Pagination
      can :manage, Achievement
    end
  end

end
