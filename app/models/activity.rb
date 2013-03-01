class Activity < ActiveRecord::Base
  attr_accessible :awarded_value, :staked_value, :stake_fullfilled

  belongs_to :event
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true
end
