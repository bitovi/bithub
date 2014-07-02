class Country < ActiveRecord::Base
  extend Solipsism
  has_many :users
end
