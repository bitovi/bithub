module Services

  class ServiceConfig
    def initialize(data, feed_name)
      @data = data
      @feed_name = feed_name
    end

    def valid?
      ServiceConfigValidator.new(@data).valid?
    end

    def data
      @data if valid?
    end

    def terms
      (@data.andand['terms'] && not(@data['terms'].empty?)) ? @data['terms'] : []
    end
    
    Feeds = %i(facebook twitter github meetup foursquare stackexchange disqus rss irc)
    Feeds.each do |feed|
      define_method("is_#{feed}?") do
        @feed_name == feed.to_s
      end
    end
  end
end
