require 'acts_as_list'

class CategoryDeterminationRule < ActiveRecord::Base

  validates_presence_of :category_name

  #acts_as_list

  after_save :create_tag

  def required_tags=(tags)
    tags = Tagger.list_to_name_weight_hash tags
    write_attribute(:required_tags, tags)
  end

  private

  def create_tag
    Tag.register category_name, 'categories'
  end
end
