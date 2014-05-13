class Tag < ActsAsTaggableOn::Tag
  serialize :props, ActiveRecord::Coders::Hstore
  attr_accessible :name, :display_name, :aliases, :props

  acts_as_taggable_on :groups

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def self.find_by_name(name)
    Tag.select {|tag| tag[:name] == name || (tag[:aliases] && tag[:aliases].include?(name)) }.first
  end
end
