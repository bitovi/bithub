class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if (account.has_role? :admin) || (ENV['RAILS_ENV'] == 'test')
      can :manage, :all
    else
      # manage it's own account
      can :manage, Account, id: account.id

      # update and leave organization
      can [:read, :update], Organization, id: account.organization_ids
      can :destroy, AccountsOrganization, account_id: account.id

      # create new a brand or read/update/delete owned brands
      can :create, Brand, organization_id: account.organization_ids
      can [:read, :update, :destroy], Brand, organization_id: account.organization_ids

      # read/destroy owned brand identities
      can [:read, :destroy], BrandIdentity, brand_id: account.brand_ids

      # countries list
      can :read, Country

      # read plans, owned subscriptions with payments
      can :read, Plan
      can :manage, Subscription, organization_id: account.organization_ids # [:read, :current]
      can :read, MonthlyBilling, subscription: {organization_id: account.organization_ids}

      can :block   , EmbedEntity
      can :approve , EmbedEntity
      can :pin     , EmbedEntity
      can :unpin   , EmbedEntity

      # models locked inside tenants
      can :manage, Embed
      can :moderate, Embed

      can :manage, Service
      can :suggest, Service

      can :manage, EmbedEntity
      can :manage, EmbedPreset
      can :manage, Entity
      can :manage, Filter
      can :manage, Grouping
      can :manage, Histogram
      can :manage, ServiceEntity
      can :manage, User
    end
  end
end
