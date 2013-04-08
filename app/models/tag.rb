class Tag < ActsAsTaggableOn::Tag 
  @tags = YAML::load_file(Rails.root.join('config', 'tags.yml'))

  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

  def to_s
    name
  end

  def self.categories
    Tag.where(:name => @tags[:category])
  end
  
  def self.projects
    Tag.where(:name => @tags[:project])
  end
  
  def self.feeds
    Tag.where(:name => @tags[:feed])
  end

  def self.category_ids
    Tag.where(:name => @tags[:category]).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => @tags[:feed]).pluck(:id)
  end

  def self.types
    @tags.keys().map{|tag| tag.to_s}
  end

end
