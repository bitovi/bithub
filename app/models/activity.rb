class Activity < ActiveRecord::Base
  class UserNotEnoughPoints < Error; end
  class EventHasNoParentError < Error; end

  attr_accessible :actor, :applies_to, :identificator, :value, :fullfilled

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true
  
  scope :upvotes, where(identificator: 'upvote')
  scope :awards, where(identificator: 'award')
  scope :stakes, where(identificator: 'stake')
  scope :stakes_and_upvotes, where(identificator: ['stake', 'upvote'])

  def self.create_upvote(actor, event)
    Activity.create({:actor => actor, :applies_to => event, :identificator => 'upvote', :value => event.rule.upvote_value})
  end

  def self.create_stake(actor, event, stake_value)
    raise UserNotEnoughPoints if actor.total_points < stake_value
    activity = Activity.create({:actor => actor, :applies_to => event, :identificator => 'stake', :value => stake_value, :fullfilled => false})
    activity
  end
  
  def self.fullfill_stakes(event)
    Activity.stakes.update_all({fullfilled: true}, {applies_to_id: event.id})
  end
  
  def self.create_award(actor, event)
    raise EventHasNoParentError if !event.parent
    total_value = event.parent.rule.award_value + event.parent.activities.stakes_and_upvotes.sum('value')
    activity = Activity.create({:actor => actor, :applies_to => event, :identificator => 'award', :value => total_value})
    Activity.fullfill_stakes(event.parent) if activity
    activity
  end

  def self.donate(actor, event, donation_value)
    Activity.create({:actor => actor, :applies_to => event, :identificator => 'donation', :value => donation_value})
  end
end
