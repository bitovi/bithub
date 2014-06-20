class AnonAbility
  include CanCan::Ability

  def initialize(user=nil)
    #cannot :manage, :all
  end
end
