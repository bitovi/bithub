class Tag < ActsAsTaggableOn::Tag 
  CATEGORIES = %w(code comment plugin app article chat bug feature)
  FEEDS = %w(github twitter disqus irc forums)
  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

  def to_s
    name
  end

  def self.category_ids
    Tag.where(:name => CATEGORIES).pluck(:id)
  end

  def self.feed_ids
    Tag.where(:name => FEEDS).pluck(:id)
  end
end
