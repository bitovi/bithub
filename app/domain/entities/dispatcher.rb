require 'entities/mappings'
require 'entities/entity'

module Entities
  module Dispatcher
    def self.dispatch(event)
      Entities.feed(event.feed).type(event.type).new(event)
    end
  end
end

# Feeds
require 'entities/feeds/blog/blog'
require 'entities/feeds/disqus/disqus'
require 'entities/feeds/forum/forum'
require 'entities/feeds/github/github'
require 'entities/feeds/twitter/twitter'
require 'entities/feeds/meetup/meetup'
