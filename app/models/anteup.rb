class Anteup < ActiveRecord::Base
  class UserNotEnoughPoints < Error; end

  attr_accessible :actor, :applies_to, :value, :fullfilled
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"
  validates_presence_of :applies_to_id, :actor_id
  scope :fullfilled, where(:fullfilled => true)

  def self.create_anteup(actor, event, value=25)
    anteup = Anteup.new({:actor => actor, :applies_to => event, :value => value, :fullfilled => false})
    if anteup.save
      event.touch
      return anteup
    else
      return nil
    end
  end

  def self.fullfill_all_for_event(event)
    fullfill_by_event(event)
  end

  def self.fullfill_by_event(event)
    Anteup.update_all({fullfilled: true}, {applies_to_id: event.id})
  end
end
