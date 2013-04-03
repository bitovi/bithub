class Tag < ActsAsTaggableOn::Tag 
  CATEGORIES = %w(code comment plugin app article chat bug feature)
  FEEDS = %w(github twitter disqus irc forums community_site)
  PROJECTS = %w(canjs donejs jquerypp)
  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

  def to_s
    name
  end

  def self.categories
    Tag.where(:name => CATEGORIES)
  end
  
  def self.projects
    Tag.where(:name => PROJECTS)
  end
  
  def self.feeds
    Tag.where(:name => FEEDS)
  end

  def self.category_ids
    Tag.where(:name => CATEGORIES).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => FEEDS).pluck(:id)
  end
end
