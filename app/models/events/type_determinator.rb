require 'events/errors'

module Events
  class TypeDeterminator
    include CoreHelpers

    def initialize(data)
      @data = symbolize_keys(data)
    end

    def type_class
      if @type_class = yield
        @type_class
      else
        fail DeterminationError.new("Non-existent Event type", source_data)
      end
    end

    private
    def source_data
      @data.fetch(:source_data)
    end
  end
end

require 'events/disqus/type_determinator'
require 'events/facebook/type_determinator'
require 'events/foursquare/type_determinator'
require 'events/github/type_determinator'
require 'events/instagram/type_determinator'
require 'events/meetup/type_determinator'
require 'events/rss/type_determinator'
require 'events/stackexchange/type_determinator'
require 'events/tumblr/type_determinator'
require 'events/twitter/type_determinator'
require 'events/youtube/type_determinator'
