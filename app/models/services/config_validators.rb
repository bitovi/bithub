module Services
  module ConfigValidators

    class HashlessString < Virtus::Attribute
      def coerce(value)
        value.gsub(/[^\w|-]/,'')
      end
    end
    

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
        attribute :hashtag, HashlessString
      end
      
      class Term
        include Virtus.model(:strict => true)
        attribute :term, HashlessString
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
        attribute :tag, HashlessString
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
        attribute :tag, HashlessString
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
        include Virtus.model
        attribute :issues, Boolean, default: false
        attribute :pull_requests, Boolean, default: false
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
        attribute :tags, Array[HashlessString]
      end
    end

    module Rss
      class Site
        include Virtus.model(:strict => true)
        attribute :url, String
        attribute :tag_with, String, required: false

        def url_as_tag(url)
          url = url.sub(/^https?\:\/\//, '').sub(/^www./,'')
          url.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
            slug.chop! if slug.last == '-'
          end
        end

        def url=(new_url)
          self.tag_with = url_as_tag(new_url) if tag_with.blank?
          super new_url
        end
      end
    end
  end
end
