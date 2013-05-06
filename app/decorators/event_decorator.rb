class EventDecorator < Draper::Decorator
  delegate_all

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
    source.respond_to?(:total_upvotes) ? source.total_upvotes.to_i : source.upvotes.reduce(0) { |acc, u| acc += u.value }
  end

  # deprecated: use 'author' or 'props.origin_author_*' attrs
  def actor
    author ? author['name'] : source.props['origin_author_name']
  end

  def has_parent
    !!parent
  end

  def author
    { :id => source.author[:id],
      :name => source.author[:name],
      :created_at => source.author[:created_at],
    } if source.author
  end

  def props
    if source.category.name == 'digest'
      source.props[:repo] = source.source_data['repo']['name'] if tag_list.include?('watch_event') || tag_list.include?('fork_event')
      source.props[:target] = source.source_data['target']['screen_name'] if tag_list.include?('follow_event')
    end
    
    if tag_list and tag_list.include?('push_event')
      source.props[:commits] = source.source_data['payload']['commits']
    end

    if source.source_data && source.source_data['user'] && source.source_data['user']['profile_image_url']
      source.props[:origin_author_avatar_url] = source.source_data['user']['profile_image_url']
    elsif source.source_data && source.source_data['actor'] && source.source_data['actor']['avatar_url']
      source.props[:origin_author_avatar_url] = source.source_data['actor']['avatar_url']
    end

    if source.parent
      source.props[:awarded] = source.awards.first ? true : false
    end

    source.props
  end

end
