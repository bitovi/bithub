class Award < ActiveRecord::Base
  class EventHasNoParentError < Error; end
  attr_accessible :actor, :applies_to, :value

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true
  validates :actor, :presence => true  
  
  def self.create_award(actor, event)
    raise EventHasNoParentError if !event.parent
    total_value = event.parent.rule.award_value + event.parent.upvotes.sum('value') + event.parent.anteups.sum('value')
    activity = Award.create({:actor => actor, :applies_to => event, :value => total_value})
    Anteup.fullfill_by_event(event.parent) if activity
    activity
  end
end
