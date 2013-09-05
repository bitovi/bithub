class Reward < ActiveRecord::Base
  attr_accessible :description, :point_minimum, :title, :image
  mount_uploader :image, RewardImageUploader

  validates :title, :point_minimum, :presence => true

  has_many :achievements
  has_many :users, :through => :achievements

end
