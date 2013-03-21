class EventDecorator < Draper::Decorator
  delegate_all

  def category_name
    category.name
  end

  def feed_name
    feed.name
  end

  def tag_names
    tags.map {|t| t.name}
  end

end
