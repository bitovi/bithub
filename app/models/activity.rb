class Activity < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :identificator, :value, :fullfilled

  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"

  validates :applies_to, :presence => true


  def self.upvote(actor, event)
    activity = Activity.new({:actor => actor, :applies_to => event, :identificator => 'upvote'})
    activity.value = event.rule.upvote_value
    activity.save!
    activity
  end

  def self.place_stake(actor, event, stake)
    # add check for available points 
    activity = Activity.new({:actor => actor, :applies_to => event, :value => stake, :fullfilled => false, :identificator => 'stake'})
    activity.save!
    activity
  end
  
  def self.award(actor, event)
    return false unless event.parent

    activity = Activity.new({:actor => actor, :applies_to => event, :identificator => 'award'})

    # sum up award
    activity.value = event.parent.rule.award_value
    sum_of_activities = Activity.where("applies_to_id=#{event.parent.id} AND identificator = ANY('{\"upvote\",\"stake\"}')").pluck('SUM(value)')
    activity.value += sum_of_activities[0].to_i unless sum_of_activities.length == 0

    if activity.save
      Activity.fullfill_stakes(event.parent)
    end

    activity   
  end

  def self.fullfill_stakes(event)
    ActiveRecord::Base.connection.execute("UPDATE activities SET fullfilled=True WHERE applies_to_id=#{event.id} AND identificator='#{:stake}';")
  end

  def self.donate(actor, event, value)
    activity = Activity.new({:actor => actor, :applies_to => event, :value => value, :identificator => 'donate'})
    activity.save!
    activity
  end

end
