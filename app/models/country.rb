class Country < ActiveRecord::Base
  attr_accessible :name, :display_name, :iso, :priority

  has_many :users

  # Helpers
  def self.has_an_attribute?(attr)
    User.reflections.include?(attr) ||
    User.reflections.include?(attr.to_s.pluralize.to_sym) ||
    User.attribute_names.include?(attr) ||
    User.attribute_names.include?(attr.to_s.pluralize.to_sym)
  end
end
