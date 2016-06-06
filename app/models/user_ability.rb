class UserAbility
  include CanCan::Ability

  def initialize(user)
    if (user.has_role? :admin) || (ENV['RAILS_ENV'] == 'test')
      can :manage, :all
    else

      # Admin of an organization
      can :manage, Organization, id: user.organization_ids

      # Admin of a brand within an organization
      can :manage, Brand, organization_id: user.organization_ids

      # can manage its own user
      can :manage, User, id: user.id

      # can read its organization information
      can [:create, :read], Organization, id: user.organization_ids

      # can read and destroy it's own organization membership
      can [:create, :read, :destroy], UserOrganization, user_id: user.id

      # can create/read/update/delete a brand
      can [:create, :read], Brand, organization_id: user.organization_ids

      # read/destroy owned brand identities
      can [:create, :read], Credential, brand_id: user.brand_ids

      # countries list
      can :read, Country

      # read plans, owned subscriptions with payments
      can :read, Plan
      can :manage, Subscription, organization_id: user.organization_ids # [:read, :current]
      can :read, Payment, subscription: { organization_id: user.organization_ids }

      can :block   , Moderation
      can :approve , Moderation
      can :pin     , Moderation
      can :unpin   , Moderation

      # models locked inside tenants
      can :manage, Hub
      can :moderate, Hub

      can :manage, Service
      can :suggest, Service

      can :manage, Moderation
      can :manage, HubEmbed
      can :manage, Bit
      can :manage, Filter
      can :manage, Histogram
      can :manage, ServiceBit
      can :manage, User
    end
  end
end
