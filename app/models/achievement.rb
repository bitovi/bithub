class Achievement < ActiveRecord::Base
  attr_accessible :note, :achieved, :shipped

  belongs_to :user
  belongs_to :reward
end
