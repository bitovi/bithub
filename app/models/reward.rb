class Reward < ActiveRecord::Base
  attr_accessible :description, :point_minimum, :title, :image, :display_point_minimum, :disabled_ts
  mount_uploader :image, RewardImageUploader
  validates_presence_of :title, :point_minimum
  has_many :achievements, :dependent => :destroy
  has_many :rewardees, :through => :achievements, :source => :user
  
  after_create :create_achievements_for_already_eligible_users

  def self.find_all_qualified_for(user)
    where("point_minimum <= ?", user.score).all
  end

  def eligible_users
    eligible_users = []
    User.all.each do |u|
      eligible_users << u if u.score >= self.point_minimum
    end
    eligible_users
  end

  def create_achievements_for_already_eligible_users
    self.eligible_users.each do |u|
      self.rewardees << u
      u.save
    end
  end

end
