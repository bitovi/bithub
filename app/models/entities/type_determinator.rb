require 'entities/errors'

require 'events/events'
require 'entities/entities'

module Entities
  class TypeDeterminator
    def initialize(event)
      @event = event
    end

    def type_class(args = {})
      if !args.empty? && (found_type_class = find_type_class(args.fetch(:namespace), args.fetch(:type_name)))
        found_type_class
      elsif block_given? && (yielded_type_class = yield)
        yielded_type_class
      else
        fail DeterminationError.new("Non-existent Entity type.", source_data)
      end
    end

    def find_type_class(namespace, type_name)
      if namespace.constants.include?(type_name)
        namespace.const_get(type_name)
      end
    end

    def source_data
      @event.source_data
    end
  end
end

require 'entities/disqus/type_determinator'
require 'entities/facebook/type_determinator'
require 'entities/foursquare/type_determinator'
require 'entities/github/type_determinator'
require 'entities/instagram/type_determinator'
require 'entities/meetup/type_determinator'
require 'entities/rss/type_determinator'
require 'entities/stackexchange/type_determinator'
require 'entities/tumblr/type_determinator'
require 'entities/twitter/type_determinator'
require 'entities/youtube/type_determinator'
