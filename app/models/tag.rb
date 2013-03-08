class Tag < ActsAsTaggableOn::Tag 
  attr_accessible :name, :display_name, :aliases, :priority
  validates :name, :presence => true, :uniqueness => true
end
