class Internal < ActiveRecord::Base
  attr_accessible :actor, :receiver, :applies_to, :value, :fullfilled

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  validates :actor, :presence => true
end
