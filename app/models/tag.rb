class Tag < ActiveRecord::Base
  attr_accessible :name, :display_name, :aliases, :is_category, :is_feed, :priority
  validates :name, :presence => true

  def self.find_or_create(name, is_category = false, is_feed = false)
    tag = Tag.where(:name => name).first
    if !tag
      tag = Tag.new({:name => name, :is_category => is_category, :is_feed => is_feed})
      tag.save!
    end
    tag
  end

  def is_category?
    is_category
  end

  def is_feed?
    is_feed
  end

end
