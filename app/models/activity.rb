class Activity < ActiveRecord::Base
  extend Enumerize
  class UserNotEnoughPoints < Error; end
  class EventHasNoParentError < Error; end
  
  attr_accessible :actor, :applies_to, :identificator, :value, :fullfilled
  attr_accessible :actor_id, :applies_to_id

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true
  
  #enumerize :identificator, in: [:donation, :upvote, :award, :internal, :stake], default: :internal, scope: true
  enumerize :identificator,
    :in => { :donation => 0,
             :upvote => 1,
             :award => 2,
             :internal => 3,
             :stake => 4
    },
    :default => :internal,
    :scope => true

  
  #scope :stakes, where(identificator: :stake)
  #scope :upvotes, where(identificator: :upvote)
  #scope :donations, where(identificator: :donation)
  #scope :awards, where(identificator: :award)
  #scope :internal, where(identificator: :internal)
  #scope :fullfilled_stakes, where(identificator: :stake, fullfilled: true)
  #scope :unfullfiled_stakes, where(identificator: :stake, fullfilled: false)
  #scope :stakes_and_upvotes, where(identificator: [:stake, :upvote])
  scope :stakes, where(identificator: 4)
  scope :upvotes, where(identificator: 1)
  scope :donations, where(identificator: 0)
  scope :awards, where(identificator: 2)
  scope :internal, where(identificator: 3)
  scope :fullfilled_stakes, where(identificator: 4, fullfilled: true)
  scope :unfullfiled_stakes, where(identificator: 4, fullfilled: false)
  scope :stakes_and_upvotes, where(identificator: [4, 1])

  def self.create_upvote(actor, event)
    Activity.create({:actor => actor, :applies_to => event, :identificator => :upvote, :value => event.rule.upvote_value})
  end

  def self.create_stake(actor, event, stake_value)
    #raise UserNotEnoughPoints if actor.sum_points < stake_value
    activity = Activity.create({:actor => actor, :applies_to => event, :identificator => :stake, :value => stake_value, :fullfilled => false})
  end
  
  def self.fullfill_stakes(event)
    Activity.stakes.update_all({fullfilled: true}, {applies_to_id: event.id})
  end
  
  def self.create_award(actor, event)
    raise EventHasNoParentError if !event.parent
    total_value = event.parent.rule.award_value + event.parent.activities.stakes_and_upvotes.sum('value')
    activity = Activity.create({:actor => actor, :applies_to => event, :identificator => :award, :value => total_value})
    Activity.fullfill_stakes(event.parent) if activity
    activity
  end

  def self.donate(actor, event, donation_value)
    Activity.create({:actor => actor, :applies_to => event, :identificator => :donation, :value => donation_value})
  end
end
