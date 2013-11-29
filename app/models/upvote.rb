class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only upvote once"

  after_create :bust_event_cache

  after_destroy :update_upvotes_in_associated_event
  after_touch :update_upvotes_in_associated_event
  after_destroy :decrease_score_in_associated_user

  def self.create_based_on_rule(actor, applies_to)
    ActiveRecord::Base.transaction do
      upvote = Upvote.create!({actor: actor, applies_to: applies_to, value: applies_to.rule.upvote_value})
      upvote.update_upvotes_in_associated_event!
      upvote.increase_score_in_associated_user!
      upvote.reward_associated_user_if_eligible
    end
    upvote
  end

  #private

  def bust_event_cache
    self.applies_to.touch
    self.applies_to.parent.touch if self.applies_to.parent
    self.applies_to.parent.parent.touch if self.applies_to.parent && self.applies_to.parent.parent
  end

  def update_upvotes_in_associated_event!
    self.applies_to.update_attribute(:total_upvotes, self.applies_to.upvotes.sum('value'))
  end
    
  def increase_score_in_associated_user!
    self.applies_to.author.total_score += self.value
    self.applies_to.author.save!
  end

  def decrease_score_in_associated_user!
    self.applies_to.author.total_score -= self.value
    self.applies_to.author.save!
  end

  def reward_associated_user_if_eligible
    self.applies_to.author.reward_if_eligible if applies_to.author
  end
end
