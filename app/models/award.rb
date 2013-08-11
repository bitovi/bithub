class Award < ActiveRecord::Base
  class EventHasNoParentError < Error; end
  class ThreadAlreadyAwardedError < Error; end

  attr_accessible :actor, :applies_to, :value
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to_id, :actor_id, :presence => true  
  validates :applies_to_id, :uniqueness => { :scope => :actor_id }
  
  def self.create_award(actor, event)
    raise ThreadAlreadyAwardedError if thread_already_awarded?(event)

    val = total_value_for_award(event)
    award = Award.new({
      :actor => actor,
      :applies_to => event,
      :value => val
    })

    if award.save
      Anteup.fullfill_all_for_event(event.parent) if event.parent
      event.touch
      return award
    else
      return nil
    end
  end

  def self.total_value_for_award(event)
    if event.parent
      p = event.parent
      return [p.rule.award_value, p.upvotes.sum('value'), p.anteups.sum('value')].reduce(&:+)
    else
      return [event.rule.award_value, event.upvotes.sum('value')].reduce(&:+)
    end
  end

  def self.thread_already_awarded?(event)
    !event.thread.select{|e| e.awarded?}.blank?
  end
end
