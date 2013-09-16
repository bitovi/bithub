class Reward < ActiveRecord::Base
  attr_accessible :description, :point_minimum, :title, :image, :display_point_minimum, :disabled_ts
  mount_uploader :image, RewardImageUploader
  validates_presence_of :title, :point_minimum
  has_many :achievements, :dependent => :destroy
  has_many :users, :through => :achievements
  
  def self.find_all_qualified_for(user)
    where("point_minimum <= ?", user.score).all
  end

end
