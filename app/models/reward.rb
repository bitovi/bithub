class Reward < ActiveRecord::Base
  attr_accessible :description, :point_minimum, :title, :image
  mount_uploader :image, RewardImageUploader
  validates_presence_of :title, :point_minimum
  has_many :achievements
  has_many :users, :through => :achievements
  
  def self.find_qualified_for(user)
    where("point_minimum < ?", user.score).order('point_minimum desc').first
  end

end
