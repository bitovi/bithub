class EventDecorator < Draper::Decorator
  S3_PREFIX = "http://s3.amazonaws.com/bithub"
  
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

  def title
    if source.tag_list.include?('status_event') && !source.source_data['entities']['urls'].blank?
      apply_hyperlinks(source.title, source.source_data['entities']['urls'])
    else
      source.title
    end
  end

  def body
    if subset?(source.tag_list, ['github','bithub']) && source.body
      markdown = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,
        :fenced_code_blocks => true,
        :no_intra_emphasis => true,
        :tables => true,
        :autolink => true,
        :strikethrough => true,
        :space_after_headers => true
      )
      markdown.render(add_newline_before_fenced_code_block(source.body)).rstrip()
    else
      source.body
    end
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

  # thumb, large, original
  def image_url(size = nil)
    case
    when has_s3_image?(source)
      S3_PREFIX + props_image_path(source.props['image'], size)    
    when has_local_image?(source)
      local_prefix + source.image.url(size)
    else
      ""
    end
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

  # TODO replace with method_missing + delegate
  def source_data
    if excluded_attributes_include?('source_data')
      nil
    else
      source.source_data
    end
  end

  private
  def has_s3_image?(event)
    !!event.props['image']
  end

  def has_local_image?(event)
    !event.image.url.blank?
  end

  def props_image_path(img_string, size)
    if !img_string.blank?
      if size == :thumb
        img_string.gsub(/(?<ext>\.\w+)$/,'_60\k<ext>')
      elsif size == :large
        img_string.gsub(/(?<ext>\.\w+)$/,'_800\k<ext>')
      else
        img_string.gsub(/(?<ext>\.\w+)$/,'_200\k<ext>')
      end
    end
  end

  def local_prefix
    case Rails.env
    when 'production'
      "http://bithub.com"
    when 'staging'
      "http://staging.bithub.com"
    when 'development'
      "http://bithub.dev"
    end
  end

  def excluded_attributes_include?(attr)
    context[:excluded_attributes] && (
      context[:excluded_attributes].include?(attr.to_sym) ||
      context[:excluded_attributes].include?(attr.to_s))
  end

  def apply_hyperlinks(text, urls)
    urls.reduce(text) do |acc, url|
      range = url['indices']; link = text.slice(*range)
      text.gsub(link, "<a href=#{url['url']}>" + url['display_url'] + "</a>") 
    end
  end
  
  # NOTE: this is a quick fix, would be better to add newlines only when they're missing
  def add_newline_before_fenced_code_block(text)
    i=0;
    text.split("```").map {|l| val = (i%2==0) ? l + "\r\n" : l; i+=1; val}.join('```')
  end

  def subset?(arr, elems)
    (arr & elems).length == elems.length
  end

end
