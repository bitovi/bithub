class Award < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to_id, :actor_id, :presence => true  
  validates :actor_id, uniqueness: { scope: :applies_to_id, message: "may only award once" }
  validate :thread_not_already_awarded

  def self.create_and_fullfill(actor, event)
    award = Award.new({
      :actor => actor,
      :applies_to => event,
      :value => total_value_for_award(event)
    })

    Anteup.fullfill_all_for_event(event.parent) if award.save && event.parent
    return award
  end

  def self.total_value_for_award(event)
    if event.parent
      p = event.parent
      return [p.rule.award_value, p.upvotes.sum('value'), p.anteups.sum('value')].reduce(&:+)
    else
      return [event.rule.award_value, event.upvotes.sum('value')].reduce(&:+)
    end
  end

  def thread_not_already_awarded
    if !applies_to.thread.select{|e| e.awarded?}.blank?
      errors.add(:applies_to, "can't already be in an awarded thread")
    end
  end
  
  def bust_event_cache
    self.applies_to.touch
  end
end
