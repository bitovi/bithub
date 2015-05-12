class EntityImagesMapper

  def initialize(source)
    @source = source
  end

  def build
    method_name = @source.feed_name + '_' + @source.type_name
    self.respond_to?(method_name, true) ? self.send(method_name) : []
  end

  private

  def tumblr_photo
    photos = JSON.parse @source.props[:photos]
    photos.map do |p|
      {
        caption: p['caption'],
        url: p['original_size']['url']
      }
    end
  end

  def twitter_tweet
    return [] unless (sem = @source.props[:entities_media])
    media = JSON.parse sem
    media.map do |m|
      { url: m['media_url'] }
    end
  end

  def instagram_media
    [{
      caption: @source.props[:caption],
      url: @source.props[:image_url]
     }]
  end

  def facebook_photo
    photos = JSON.parse @source.props[:photos]
    photos.map do |p|
      {
        caption: '',
        url: p['url']
      }
    end
  end

  def youtube_video
    { caption: 'Thumbnail', url: @source.image }
  end

end
