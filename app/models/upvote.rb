class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only upvote once"

  after_create :bust_event_cache
  after_destroy :update_entities_and_user

  def self.create_based_on_rule(actor, applies_to)
    upvote = nil
    ActiveRecord::Base.transaction do
      upvote = Upvote.create!({actor: actor, applies_to: applies_to, value: applies_to.scoring_rule.upvote_value})
      upvote.update_total_upvotes_in_associated_entity
      upvote.update_total_score_in_associated_user
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

  def update_total_upvotes_in_associated_entity
    self.applies_to.async_update_total_upvotes
  end
    
  def update_total_score_in_associated_user
    self.applies_to.author.async_update_total_score if self.applies_to.author
  end

  def reward_associated_user_if_eligible
    self.applies_to.author.async_reward_if_eligible if self.applies_to.author
  end

  def unreward_associated_user_if_uneligible
    self.applies_to.author.async_unreward_if_uneligible if self.applies_to.author
  end

  def update_entities_and_user
    update_total_upvotes_in_associated_entity
    update_total_score_in_associated_user
    unreward_associated_user_if_uneligible
  end
end
