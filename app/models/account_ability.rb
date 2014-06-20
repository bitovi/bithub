class AccountAbility
  include CanCan::Ability

  def initialize(account)
    if user.has_role? :admin
      can :manage, :all
    else
      can :read, :all
    end
  end
end
