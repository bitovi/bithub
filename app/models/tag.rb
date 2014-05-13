class Tag < ActsAsTaggableOn::Tag
  serialize :props, ActiveRecord::Coders::Hstore
  attr_accessible :name, :display_name, :aliases, :props

  acts_as_taggable_on :groups

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def add_group(name)
    group_list.push(name)
  end

  def remove_group(name)
    group_list.remove(name)
  end

  def self.find_by_name(name)
    Tag.select do |tag|
      tag[:name] == name || tag[:aliases].andand.include?(name)
    end.first
  end

  ### app/domain/query_logic/query.rb
  def self.categories_order
    tagged_with('categories').order("props -> 'order_on_page'").pluck(:id)
  end
end
