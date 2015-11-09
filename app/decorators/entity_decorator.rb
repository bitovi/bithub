class EntityDecorator < Draper::Decorator
  delegate_all

  def title
    if ['tweet', 'follow'].include?(source.type_name)
      apply_hyperlinks(source.title, source.props['entities_urls'])
    else
      source.title
    end
  end

  def body
    if ['github','stackexchange'].include?(source.feed_name) && source.body
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

  def is_approved
    current_embed = context.fetch(:embed)
    source.is_approved(current_embed)
  end

  def is_pinned
    current_embed = context.fetch(:embed)
    source.is_pinned(current_embed)
  end
  
  def decision
    current_embed = context.fetch(:embed)
    source.decision(current_embed)
  end

  def images
    EntityImagesMapper.new(source).build
  end

  def has_parent
    !!parent
  end

  def apply_hyperlinks(text, urls )
    urls = JSON.parse(urls || '[]')

    urls.reduce(text) do |acc, url|
      range = url["indices"]
      link = text.slice(*range)
      text.gsub(link, url["display_url"])
    end

    Twitter::Autolink.auto_link(text)
  end
  
  def quoted_status
    TweetQuote.new(source).build
  end


  # NOTE: this is a quick fix, would be better to add newlines only when they're missing
  def add_newline_before_fenced_code_block(text)
    i=0;
    text.split("```").map {|l| val = (i%2==0) ? l + "\r\n" : l; i+=1; val}.join('```')
  end

  def contains?(arr, elems)
    (arr & elems).length > 0
  end

end
