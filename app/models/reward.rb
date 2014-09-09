class Reward < ActiveRecord::Base

  mount_uploader :image, RewardImageUploader

  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements, :source => :user

  validates_presence_of :title, :point_minimum

  #after_create :reward_all_eligible_users

  def reward_all_eligible_users
    Users::RewardEligiblityDecider.new(reward: self).reward_all_eligible_users
  end
end
