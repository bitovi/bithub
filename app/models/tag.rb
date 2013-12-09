class Tag < ActsAsTaggableOn::Tag 
  @tag_groups = YAML::load_file(Rails.root.join('config', 'tag_groups.yml'))

  serialize :props, ActiveRecord::Coders::Hstore
  
  attr_accessible :name, :display_name, :aliases, :props
  validates_presence_of :name
  validates_uniqueness_of :name

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
