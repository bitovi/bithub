class Award < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id, :actor_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only award once"
  validate :thread_not_already_awarded

  class EventHasNoParentException < Exception; end

  def self.create_with_strategy(actor, applies_to, opts = {})
    opts = { :strategy => :double_the_upvotes } if opts.empty?

    begin
      if opts[:strategy] == :double_the_upvotes
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.double_upvote_value(applies_to)})
      elsif opts[:strategy] == :double_parents_upvotes
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.double_parents_upvote_value(applies_to)})
      elsif opts[:strategy] == :based_on_rule
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.total_value(applies_to)})
      end
    rescue EventHasNoParentException => e
      Rails.logger.info "Event can't be awarded because it has no parent" 
      raise e
    end

    applies_to.author.reward_if_eligible if applies_to.author
    award
  end

  def self.double_upvote_value(event)
    (event.upvotes.sum(:value) * 2)
  end
  
  def self.double_parents_upvote_value(event)
    if self.parent
      (event.parent.upvotes.sum(:value) * 2)
    else
      fail EventHasNoParentException
    end
  end

  def self.total_value(event)
    if p = event.parent
      [p.rule.award_value, p.upvotes.sum('value'), p.anteups.sum('value')].reduce(&:+)
    else
      [event.rule.award_value, event.upvotes.sum('value')].reduce(&:+)
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
