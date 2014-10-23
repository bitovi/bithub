class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if account.has_role? :admin
      can :manage, :all
    else
      can [:read, :read_tags_tree], Tag
      can [:read, :update], Brand #, id: account.brand.id
      can [:destroy], BrandIdentity #, brand_id: account.brand.id
      can :read, Country
      can :manage, Embed
      can :read, User # TODO check somehow if user is present in current tenant
      can :manage, Service #, brand_id: account.brand.id
      can :manage_roles_on_user, User
      can :manage, Entity
    end
  end

end
