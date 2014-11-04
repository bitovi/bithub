require 'literate_ruby'

module Services

  class ServiceConfigValidator
    include LiterateRuby

    def initialize(data, feed_name)
      @data = data
      @feed_name = feed_name
      @errors = { missing: [] }
    end
    attr_reader :errors

    def valid?
      return unless respond_to? (mff = "valid_#{@feed_name}?")
      send(mff)
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
      returning(@data.fetch('pages').all?{|page| page.has_key?('access_token')}) do
        @errors[:missing] << 'pages -> access_token'
      end
    end

    def has?(key)
      returning (
        @data\
        && @data.instance_of?(Hash)\
        && @data.has_key?(key)\
        && not(@data[key].empty?)
      ) do |it_has|
        @errors[:missing] << key unless it_has
      end
    end
  end
end
