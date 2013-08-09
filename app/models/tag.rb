class Tag < ActsAsTaggableOn::Tag 
  @tag_names = YAML::load_file(Rails.root.join('config', 'tag_names.yml'))

  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

  def to_s
    name
  end

  def self.categories
    Tag.where(:name => @tag_names[:category])
  end
  
  def self.projects
    Tag.where(:name => @tag_names[:project])
  end
  
  def self.feeds
    Tag.where(:name => @tag_names[:feed])
  end

  def self.category_ids
    Tag.where(:name => @tag_names[:category]).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => @tag_names[:feed]).pluck(:id)
  end

  def self.types
    @tag_names.keys().map{|tag| tag.to_s}
  end

end
