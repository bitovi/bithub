module Services
  class ServiceConfig

    def initialize(service)
      @service = service
      @feed_name = service.feed_name
      @type_name = service.type_name
      @errors    = []
      @config    = virtus_class.new(service.config)
    rescue => e
      @errors.push({ klass: e.class, message: e.message })
    end
    attr_reader :config, :errors

    def data
      @config.to_h if valid?
    end

    def property_id
      @config.id if @config.respond_to? :id
    end

    def valid?
      @errors.empty?
    end

    def humanized_config
      if @config.respond_to?(:'humanized_name=')
        @config.humanized_name = @service.credential.property_name_for_id(property_id)
      end
      @config.to_h
    end

    def error_msg
      @errors.map {|err| err[:message]}
    end

    private

    def virtus_class
      types = Services::Types
      feed = @feed_name.to_s.camelize
      type = @type_name.to_s.camelize

      if types.const_defined?(feed, false) && types.const_get(feed).const_defined?(type, false)
        types.const_get(feed).const_get(type)
      else
        fail NameError.new("unknown feed/type, feed: #{feed}, type: #{type}" )
      end
    end
  end
end

# god damned auto loading
Services::Types::Disqus::Forum

Services::Types::Facebook::Page
Services::Types::Facebook::PublicPage

Services::Types::Foursquare::Venue

Services::Types::Github::Org
Services::Types::Github::Repo

Services::Types::Instagram::Tag
Services::Types::Instagram::User
Services::Types::Instagram::LikedMedia

Services::Types::Meetup::Group

Services::Types::Rss::Site

Services::Types::Stackexchange::Tags

Services::Types::Tumblr::Blog
Services::Types::Tumblr::Tag

Services::Types::Twitter::Followers
Services::Types::Twitter::Hashtag
Services::Types::Twitter::Term
Services::Types::Twitter::UserTimeline
Services::Types::Twitter::UserRetweets
Services::Types::Twitter::Favorites

Services::Types::Youtube::Channel
Services::Types::Youtube::Playlist
Services::Types::Youtube::User
