class Anteup < ActiveRecord::Base
  class UserNotEnoughPoints < Error; end
  attr_accessible :actor, :applies_to, :value, :fullfilled

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true
  validates :actor, :presence => true

  scope :fullfilled, where(:fullfilled => true)

  def self.create_anteup(actor, event, value=nil)
    value ||= 25
    Anteup.create({:actor => actor, :applies_to => event, :value => value, :fullfilled => false})
  end

  def self.fullfill_by_event(event)
    Anteup.update_all({fullfilled: true}, {applies_to_id: event.id})
  end
end
