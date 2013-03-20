class Tag < ActsAsTaggableOn::Tag 
  CATEGORIES = %w(code comment plugin app article)
  FEEDS = %w(github twitter disqus)
  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true

  def to_s
    name
  end
end
