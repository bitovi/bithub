class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to_id, :actor_id, :presence => true
  validates :actor_id, uniqueness: { scope: :applies_to_id, message: "may only upvote once" }

  def bust_event_cache
    self.applies_to.touch
  end
end
