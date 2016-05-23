require 'bits/errors'

require 'events/events'
require 'bits/bits'

module Bits
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
        fail DeterminationError.new("Non-existent Bit type.", source_data)
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

require 'bits/disqus/type_determinator'
require 'bits/facebook/type_determinator'
require 'bits/foursquare/type_determinator'
require 'bits/github/type_determinator'
require 'bits/instagram/type_determinator'
require 'bits/meetup/type_determinator'
require 'bits/rss/type_determinator'
require 'bits/stackexchange/type_determinator'
require 'bits/tumblr/type_determinator'
require 'bits/twitter/type_determinator'
require 'bits/youtube/type_determinator'
