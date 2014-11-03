module Services

  class ServiceConfig
    def initialize(data, feed_name)
      @data = data
      @feed_name = feed_name
    end

    def valid?
      @validator ||= ServiceConfigValidator.new(@data, @feed_name)
      @validator.valid?
    end
    
    def errors
      { missing_keys: @validator.errors[:missing] }
    end

    def error_msg
      "missing keys: #{@validator.errors[:missing].join(' ')}"
    end

    def data
      @data if valid?
    end

    def terms
      (@data.andand['terms'] && not(@data['terms'].empty?)) ? @data['terms'] : []
    end

    def tags
      ConfigTagPlucker.new(@data).tags if valid?
    end
    
    Feeds = %i(facebook twitter github meetup foursquare stackexchange disqus rss irc)
    Feeds.each do |feed|
      define_method("is_#{feed}?") do
        @feed_name == feed.to_s
      end
    end
  end
end
