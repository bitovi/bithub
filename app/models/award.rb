class Award < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value

  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only award once"
  validate :thread_not_already_awarded
  
  after_create :bust_event_cache
  after_destroy :update_user_and_entity

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
      award.update_total_score_in_associated_user
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
      [p.scoring_rule.award_value, p.upvotes.sum('value')].reduce(&:+)
    else
      [event.scoring_rule.award_value, event.upvotes.sum('value')].reduce(&:+)
    end
  end

  # Validator
  def thread_not_already_awarded
    flag = applies_to.thread
    .select{|e| e.awarded?}
    .map{|e| !e.awards.include?(self)}
    .reduce(false) {|acc, v| acc && v}
      
    if flag
      errors.add(:applies_to, "can't already be in an awarded thread")
    end
  end

  # Methods for hooks
  def bust_event_cache
    applies_to.touch
    applies_to.parent.touch if self.applies_to.parent
    applies_to.parent.parent.touch if self.applies_to.parent && self.applies_to.parent.parent
  end

  def update_total_score_in_associated_user
    applies_to.author.async_update_total_score if self.applies_to.author
  end

  def reward_associated_user_if_eligible
    applies_to.author.async_reward_if_eligible if self.applies_to.author
  end

  def unreward_associated_user_if_uneligible
    applies_to.author.async_unreward_if_uneligible if self.applies_to.author
  end

  def update_user_and_entity
    update_total_score_in_associated_user
    unreward_associated_user_if_uneligible
  end

end
