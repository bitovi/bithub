class Reward < ActiveRecord::Base
  attr_accessible :title, :description, :point_minimum, :image, :display_point_minimum, :disabled_ts

  mount_uploader :image, RewardImageUploader

  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements, :source => :user

  validates_presence_of :title, :point_minimum

  after_create :reward_all_eligible_users

  def reward_all_eligible_users
    RewardEligiblityDecider.new(reward: self).reward_all_eligible_users
  end
end
