class TweetQuote
  def initialize(source)
    @quoted_status = source.events.last.source_data['quoted_status']
  end

  def build
    unless @quoted_status.blank?
      {
        title: Twitter::Autolink.auto_link(@quoted_status["text"]),
        url: "https://twitter.com/#{@quoted_status["user"]["screen_name"]}/status/#{@quoted_status["id_str"]}",
        author: {
          id: @quoted_status["user"]["name"],
          avatar_url: @quoted_status["user"]["profile_image_url"]
        }
      }
    end
  end
end
