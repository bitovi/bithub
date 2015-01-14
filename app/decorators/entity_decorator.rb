require 'pp'
class EntityDecorator < Draper::Decorator

  delegate_all

  def tag_names
    cached_tags
  end

  def title
    if source.cached_tags.include?('tweet')
      apply_hyperlinks(source.title, source.props['entities_urls'])
    else
      source.title
    end
  end

  def body
    if (contains? source.cached_tags, ['github','stackexchange','bithub']) && source.body
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

  def images
    if source.feed_name == 'tumblr' && source.type_name == 'photo'
      photos = JSON.parse(source.props['photos'] || source.props[:photos])
      photos.map do |p|
        {
          caption: p['caption'],
          url: p['original_size']['url']
        }
      end
    end

    if source.feed_name == 'instagram' && source.type_name == 'media'
      [{
        caption: source.source_data['caption'].andand['text'] || '',
        url: source.source_data['images']['standard_resolution']['url'],
       }]
    end
  end

  def has_parent
    !!parent
  end

  def apply_hyperlinks(text, urls )
    urls = ActiveSupport::JSON.decode(urls || '[]')

    urls.reduce(text) do |acc, url|
      range = url["indices"]
      link = text.slice(*range)
      text.gsub(link, url["display_url"])
    end

    Twitter::Autolink.auto_link(text)
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
