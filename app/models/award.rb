class Award < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only award once"
  validate :thread_not_already_awarded
  
  after_create :bust_event_cache
  after_destroy :decrease_score_in_associated_user

  def self.create_based_on_strategy(actor, applies_to, opts = {})
    opts = { :strategy => :double_the_upvotes } if opts.empty?
    award = nil
    
    ActiveRecord::Base.transaction do
      case opts[:strategy]
      when :double_the_upvotes
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.double_upvote_value(applies_to)})
      when :double_parents_upvotes
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.double_parents_upvote_value(applies_to)})
      when :based_on_rule
        award = Award.create!({actor: actor, applies_to: applies_to, value: Award.rule_based_value(applies_to)})
      end
      award.increase_score_in_associated_user!
      award.reward_associated_user_if_eligible
    end
    
    award
  end


  #private
  
  # Strategies
  def self.double_upvote_value(event)
    (event.upvotes.sum(:value) * 2)
  end
  
  def self.double_parents_upvote_value(event)
    (event.top_level_parent.upvotes.sum(:value) * 2) if event.parent
  end
  
  def self.rule_based_value(event)
    if p = event.parent
      [p.rule.award_value, p.upvotes.sum('value')].reduce(&:+)
    else
      [event.rule.award_value, event.upvotes.sum('value')].reduce(&:+)
    end
  end

  # Validator
  def thread_not_already_awarded
    if !applies_to.thread.select{|e| e.awarded?}.blank?
      errors.add(:applies_to, "can't already be in an awarded thread")
    end
  end

  # Methods for hooks
  def bust_event_cache
    self.applies_to.touch
    self.applies_to.parent.touch if self.applies_to.parent
    self.applies_to.parent.parent.touch if self.applies_to.parent && self.applies_to.parent.parent
  end

  def increase_score_in_associated_user!
    if self.applies_to.author
      self.applies_to.author.total_score += self.value
      self.applies_to.author.save!
    end
  end

  def decrease_score_in_associated_user!
    if self.applies_to.author
      self.applies_to.author.total_score -= self.value
      self.applies_to.author.save!
    end
  end

  def reward_associated_user_if_eligible
    self.applies_to.author.reward_if_eligible if self.applies_to.author
  end
end
