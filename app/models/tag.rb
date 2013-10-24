class Tag < ActsAsTaggableOn::Tag 
  @tag_groups = YAML::load_file(Rails.root.join('config', 'tag_groups.yml'))

  attr_accessible :name, :display_name, :aliases, :priority
  validates_presence_of :name
  validates_uniqueness_of :name

  validate :check_for_junk_tags

  def to_s
    name
  end

  def self.categories
    Tag.where(:name => @tag_groups[:category])
  end
  
  def self.projects
    Tag.where(:name => @tag_groups[:project])
  end
  
  def self.feeds
    Tag.where(:name => @tag_groups[:feed])
  end

  def self.labels
    Tag.where(:name => @tag_groups[:label])
  end

  def self.category_ids
    Tag.where(:name => @tag_groups[:category]).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => @tag_groups[:feed]).pluck(:id)
  end

  def self.types
    @tag_groups.keys().map{|tag| tag.to_s}
  end

  def self.find_by_name(name)
    Tag.select {|tag| tag[:name] == name || (tag[:aliases] && tag[:aliases].include?(name)) }.first
  end

  def check_for_junk_tags
    if name =~ /\./
      errors.add(:name, "can't contain dots as they break the client app")
    end
  end
  
end
