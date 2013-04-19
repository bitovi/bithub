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

  def award_value
    source.rule.award_value
  end

  def awarded
    source.awards.first
  end

  def anteups
    source.anteups.sum(:value)
  end

  def upvotes
    if source.methods.include?(:total_upvotes)
      source.total_upvotes.to_i
    else
      source.upvotes.reduce(0) { |acc, u| acc += u.value }
    end
  end

  def actor
    if author
      author['name']
    else
      props['origin_author_name']
    end
  end

  def commits
    if tag_list and tag_list.include?('push_event')
      source_data['payload']['commits']
    end
  end

end
