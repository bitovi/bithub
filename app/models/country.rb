class Country < ActiveRecord::Base
  attr_accessible :name, :display_name, :iso, :priority

  has_many :users

end
