class Tag < ActsAsTaggableOn::Tag 
  @tag_groups = YAML::load_file(Rails.root.join('config', 'tag_groups.yml'))

  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

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

  def self.category_ids
    Tag.where(:name => @tag_groups[:category]).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => @tag_groups[:feed]).pluck(:id)
  end

  def self.types
    @tag_groups.keys().map{|tag| tag.to_s}
  end

end
