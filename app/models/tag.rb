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
    group_list.push name.snake_case
    self
  end

  def add_groups(names)
    names = names.split(/[\s,]+/) if names.kind_of? String
    names.each {|n| add_group n}
    self
  end

  def remove_group(name)
    group_list.remove name.snake_case
    self
  end

  def remove_groups(names)
    names = names.split(/[\s,]+/) if names.kind_of? String
    names.each {|n| remove_group n}
    self
  end

  def self.find_by_name(name)
    Tag.select do |tag|
      tag[:name] == name || tag[:aliases].andand.include?(name)
    end.first
  end

  def self.register(name, groups=[])
    name = name.snake_case

    tag = find_by_name(name) || Tag.new({name: name})
    tag.add_groups groups

    tag.save ? tag : nil
  end

  def self.unregister(name)
    if tag = find_by_name(name)
      tag.destroy
    end
  end

  def self.remove_group(name, group)
    if tag = find_by_name(name)
      tag.remove_group(group).save
    end
  end
end
