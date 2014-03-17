class Brand < ActiveRecord::Base

  attr_accessible :name, :display_name, :description, :keywords, :props

  serialize :props, ActiveRecord::Coders::Hstore

  has_many :accounts
end
