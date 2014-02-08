class Tag < ActsAsTaggableOn::Tag 
  serialize :props, ActiveRecord::Coders::Hstore  
  attr_accessible :name, :display_name, :aliases, :props

  acts_as_taggable_on :groups
  
  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def self.categories
    self.tagged_with('categories')
  end
  
  def self.projects
    self.tagged_with('projects')
  end
  
  def self.feeds
    self.tagged_with('feeds')
  end

  def self.labels
    self.tagged_with('labels')
  end

  def self.category_names
    self.categories.pluck(:name)
  end

  def self.feed_names
    self.feeds.pluck(:name)
  end

  def self.project_names
    self.projects.pluck(:name)
  end

  def self.category_ids
    self.categories.pluck(:id)
  end

  def self.feed_ids
    self.feeds.pluck(:id)
  end

  def self.group_names
    Tag.group_counts.pluck(:name)
  end

  def self.categories_order
    @categories_order ||= self.categories.order("props -> 'order_on_page'").pluck(:id)
  end

  ###
  def self.to_name_aliases_hash(group)
    Hash[ Tag.where(:name => @tag_groups[group]).map {|tag| [tag.name, tag.aliases || [tag.name]]} ]
  end

  def self.to_hash_list(group = nil)
    tags = @tag_groups[group] ? Tag.where(:name => @tag_groups[group]) : Tag.all
    
    tags.map do |t|
      {
        name: t.name,
        aliases: t.aliases
      }.merge(t.props.symbolize_keys)
    end
  end
  
  def self.find_by_name(name)
    Tag.select {|tag| tag[:name] == name || (tag[:aliases] && tag[:aliases].include?(name)) }.first
  end
end
