class Award < ActiveRecord::Base
  class EventHasNoParentError < Error; end
  class ThreadAlreadyAwardedError < Error; end

  attr_accessible :actor, :applies_to, :value
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to_id, :actor_id, :presence => true  
  validates :applies_to_id, :uniqueness => { :scope => :actor_id }
  
  def self.create_award(actor, event)
    raise EventHasNoParentError if !event.parent
    raise ThreadAlreadyAwardedError if thread_already_awarded?(event)

    val = total_value_for_award(event)
    award = Award.new({
      :actor => actor,
      :applies_to => event,
      :value => val
    })

    if award.save
      Anteup.fullfill_all_for_event(event.parent)
      event.touch
      return award
    else
      return nil
    end
  end

  def self.total_value_for_award(event)
    raise EventHasNoParentError if !event.parent
    [event.parent.rule.award_value,
      event.parent.upvotes.sum('value'),
      event.parent.anteups.sum('value')].reduce(&:+)
  end

  def self.thread_already_awarded?(event)
    !event.siblings.select { |e| e.awarded? }.blank?
  end
end
