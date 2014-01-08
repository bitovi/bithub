require 'lib/sanitizer'
require 'events/feeds/forum/types/post'

module Events
  module Forum

    class Processor
      def initialize
        @config = yield if block_given?
      end

      def process(original_hash, processed)
        processed.deep_merge({
          meta: {
            feed: 'forum',
            type: 'post',
            tags: [@config.andand[:term]],
          }
        })
      end
      
      def determine_event_type(original_hash)
        "Post"
      end

      def events_from_response(response)
        response['rss']['channel']['item']
      end
    end

  end
end
