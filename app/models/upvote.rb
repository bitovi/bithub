class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"
  validates :applies_to, :presence => true
  # validates :actor, :presence => true

  def self.create_upvote(actor, event)
    Upvote.create({:actor => actor, :applies_to => event, :value => event.rule.upvote_value})
    event.touch # For fragment cache invalidation
  end
end
