class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  after_save :bust_event_cache

  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only upvote once"

  after_create :bust_event_cache

  def bust_event_cache
    self.applies_to.touch
    self.applies_to.parent.touch if self.applies_to.parent
    self.applies_to.parent.parent.touch if self.applies_to.parent && self.applies_to.parent.parent
  end

end
