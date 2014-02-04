class Anteup < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value, :fullfilled

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  scope :fullfilled, where(:fullfilled => true)
  
  validates_presence_of :applies_to_id, :actor_id

  def self.create_anteup(actor, event, value=25)
    if (anteup = Anteup.create({:actor => actor, :applies_to => event, :value => value, :fullfilled => false}))
      event.touch
      anteup
    end
  end

  def self.fullfill_all_for_event(event)
    fullfill_by_event(event)
  end

  def self.fullfill_by_event(event)
    Anteup.update_all({fullfilled: true}, {applies_to_id: event.id})
  end
end
