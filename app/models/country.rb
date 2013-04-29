class Country < ActiveRecord::Base
  attr_accessible :name, :display_name, :iso

  has_many :users

end
