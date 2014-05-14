require 'acts_as_list'

class CategoryDeterminationRule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :required_tags, :category_name, :position
  serialize :required_tags, ActiveRecord::Coders::Hstore

  validates_presence_of :category_name

  acts_as_list
end
