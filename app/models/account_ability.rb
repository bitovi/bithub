class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if (account.has_role? :admin) || (ENV['RAILS_ENV'] == 'test')
      can :manage, :all
    else
      can [:read, :read_tags_tree], Tag
      can [:read, :update], Brand #, id: account.brand.id
      can [:read, :destroy], BrandIdentity #, brand_id: account.brand.id
      can :manage, Account, id: account.id
      can :read, Country
      can :read, User # TODO check somehow if user is present in current tenant
      can :read, Payment
      can :manage, Embed
      can :manage, Filter
      can :manage, Service #, brand_id: account.brand.id
      can :manage_roles_on_user, User
      can :manage, Entity
    end
  end

end
