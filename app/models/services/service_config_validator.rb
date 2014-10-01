module Services

  class ServiceConfigValidator

    def initialize(data, feed_name)
      @data = data
      @feed_name = feed_name
    end

    def valid?
      send("valid_#{@feed_name}?")
    end

    def valid_github?
      has?('orgs') || has?('repos')
    end

    def valid_facebook?
      has?('pages') && pages_have_tokens?
    end

    def valid_twitter?
      has?('terms')
    end

    def valid_meetup?
      has?('groups') || has?('terms')
    end

    def valid_foursquare?
      has?('venues')
    end

    def valid_rss?
      has?('sites')
    end

    def valid_irc?
      has?('chats')
    end

    def valid_disqus?
      has?('forums')
    end

    def valid_stackexchange?
      has?('tags')
    end

    def valid_instagram?
      has?('users') || has?('tags') || has?('locations') || has?('geographies')
    end

    def pages_have_tokens?
      @data.fetch('pages').all?{|page| page.has_key?('access_token')}
    end

    def has?(key)
      @data\
        && @data.instance_of?(Hash)\
        && @data.has_key?(key)\
        && not(@data[key].empty?)
    end
  end
end
