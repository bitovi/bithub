class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if account.has_role? :admin
      can :manage, :all
    else
      can :read, Tag
      can :read, BrandIdentity
      can [:read, :update], Brand
      can :read, Country
      can [:read, :update], ScoringRule
      can :manage, Reward
      can :manage, FeedConfig
      can :read, User
      can [:read, :destroy], Entity
      can :create_award, Award
      can :read_pagination, Pagination
      can :manage, Achievement
    end
  end

end
