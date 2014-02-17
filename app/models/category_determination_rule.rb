class CategoryDeterminationRule < ActiveRecord::Base
  attr_accessible :name, :scorings
  serialize :scorings, ActiveRecord::Coders::Hstore

  validates_uniqueness_of :name
end
