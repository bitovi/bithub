class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id, :actor_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only upvote once"

  def self.create_based_on_rule(actor, applies_to)
    upvote = Upvote.create!({actor: actor, applies_to: applies_to, value: applies_to.rule.upvote_value})
    upvote_value.bust_event_cache
    applies_to.author.reward_if_eligible if applies_to.author
    upvote
  end

  def bust_event_cache
    self.applies_to.touch
  end
end
