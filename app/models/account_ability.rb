class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if (account.has_role? :bithub_admin) || (ENV['RAILS_ENV'] == 'test')
      can :manage, :all
    else

      # Admin of an organization
      can :manage, Organization, id: account.organization_ids

      # Admin of a brand within an organization
      can :manage, Brand, organization_id: account.organization_ids

      # can manage its own account
      can :manage, Account, id: account.id

      # can read its organization information
      can [:create, :read], Organization, id: account.organization_ids

      # can read and destroy it's own organization membership
      can [:create, :read, :destroy], AccountOrganization, account_id: account.id

      # can create/read/update/delete a brand
      can [:create, :read], Brand, organization_id: account.organization_ids

      # read/destroy owned brand identities
      can [:create, :read], BrandIdentity, brand_id: account.brand_ids

      # countries list
      can :read, Country

      # read plans, owned subscriptions with payments
      can :read, Plan
      can :manage, Subscription, organization_id: account.organization_ids # [:read, :current]
      can :read, Payment, subscription: {organization_id: account.organization_ids}

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
      can :manage, Histogram
      can :manage, ServiceEntity
      can :manage, User
    end
  end
end
