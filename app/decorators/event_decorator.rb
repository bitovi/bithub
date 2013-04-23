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

  # deprecated: use 'author' or 'props.origin_author_*' attrs
  def actor
    if author
      author['name']
    else
      props['origin_author_name']
    end
  end

  def author_deco
    if author
      {
        :id => author['id'],
        :name => author[:name],
        :created_at => author[:created_at],
      }
    end
  end

  def props_deco
    if category.name == 'digest'
      props[:repo] = source_data['repo']['name'] if tag_list.include?('watch_event') || tag_list.include?('fork_event')
      props[:target] = source_data['target']['screen_name'] if tag_list.include?('follow_event')
    end
    
    if tag_list and tag_list.include?('push_event')
      props[:commits] = source_data['payload']['commits']
    end

    if source_data && source_data['user'] && source_data['user']['profile_image_url']
      props[:origin_author_avatar_url] = source_data['user']['profile_image_url']
    elsif source_data && source_data['actor'] && source_data['actor']['avatar_url']
      props[:origin_author_avatar_url] = source_data['actor']['avatar_url']
    end

    props
  end

end
