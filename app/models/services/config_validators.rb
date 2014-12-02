module Services
  module ConfigValidators

    module Twitter
      class UserTimeline
        include Virtus.model(:strict => true)
        attribute :handle, String
      end

      class Followers
        include Virtus.model(:strict => true)
        attribute :handle, String
      end

      class Hashtag
        include Virtus.model(:strict => true)
        attribute :hashtag, String
      end
    end

    module Disqus
      class Forum
        include Virtus.model(:strict => true)
        attribute :url, String
      end
    end

    module Facebook
      class Page
        include Virtus.model(:strict => true)
        attribute :id, String
      end
    end

    module Foursquare
      class Venue
        include Virtus.model(:strict => true)
        attribute :id, String
      end
    end

    module Instagram
      class User
        include Virtus.model(:strict => true)
        attribute :id, String
      end

      class Tag
        include Virtus.model(:strict => true)
        attribute :tag, String
      end

      class Location
        include Virtus.model(:strict => true)
        attribute :id, String
      end

      class Geography
        include Virtus.model(:strict => true)
        attribute :lat, String
        attribute :lng, String
        attribute :radius, String
      end
    end

    module Tumblr
      class Blog
        include Virtus.model(:strict => true)
        attribute :hostname, String
      end

      class Tag
        include Virtus.model(:strict => true)
        attribute :tag, String
      end
    end

    module Meetup
      class Group
        include Virtus.model(:strict => true)
        attribute :id, String
      end
    end

    module Github
      class Tracking
        include Virtus.model(:strict => true)
        attribute :issues, Boolean
        attribute :pull_requests, Boolean
      end

      class Repo
        include Virtus.model(:strict => true)
        attribute :name, String
        attribute :tracking, Tracking
      end

      class Org
        include Virtus.model(:strict => true)
        attribute :name, String
      end
    end

    module Stackexchange
      class Tags
        include Virtus.model(:strict => true)
        attribute :tags, Array[String]
      end
    end

    module Rss
      class Site
        include Virtus.model(:strict => true)
        attribute :url, String
        attribute :tag_with, Array[String]
      end
    end
  end
end
