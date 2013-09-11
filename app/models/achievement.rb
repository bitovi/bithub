class Achievement < ActiveRecord::Base
  attr_accessible :note, :achieved_at, :shipped_at

  belongs_to :user
  belongs_to :reward
  validates_uniqueness_of :user_id, :scope => :reward_id, message: "can only have one achievement for a specific reward"
  

  after_create :set_timestamp

  def set_timestamp
    self.update_attribute(:achieved_at, Time.now)
  end

  def self.reject_achieved_rewards(user, rewards)
    rewards.reject {|r| user.rewards.include?(r)}
  end
end
