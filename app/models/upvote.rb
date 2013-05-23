class Upvote < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to_id, :actor_id, :presence => true

  def self.create_upvote(actor, event)
    upvote = Upvote.new({:actor => actor, :applies_to => event, :value => event.rule.upvote_value})
    if upvote.save
      event.touch # Cache busting
      return upvote
    else
      return nil
    end
  end
end
