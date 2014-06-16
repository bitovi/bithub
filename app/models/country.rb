class Country < ActiveRecord::Base
  extend Solipsism

  attr_accessible :name, :display_name, :iso, :priority
  has_many :users
end
