class Account < ActiveRecord::Base

  attr_accessible :email, :password, :name, :props

  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :brand
end
