class CategoryDeterminationRule < ActiveRecord::Base
  attr_accessible :name, :required_tags, :category_name
  serialize :required_tags, ActiveRecord::Coders::Hstore

  validates_presence_of :category_name
end
