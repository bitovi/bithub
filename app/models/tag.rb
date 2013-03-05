class Tag < ActiveRecord::Base
  attr_accessible :display_name, :name

  validates :name, :presence => true
end
