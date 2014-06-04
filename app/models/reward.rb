class Reward < ActiveRecord::Base
  attr_accessible :description, :point_minimum, :title, :image, :display_point_minimum, :disabled_ts
  mount_uploader :image, RewardImageUploader
  validates_presence_of :title, :point_minimum
  has_many :achievements, :dependent => :destroy
  has_many :rewardees, :through => :achievements, :source => :user
  
  after_create :reward_all_eligible_users

  def reward_all_eligible_users
    Users::RewardEligiblityDecider.new(reward: self).reward_all_eligible_users
  end
end
