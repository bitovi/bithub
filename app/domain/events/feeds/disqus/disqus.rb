require 'events/feeds/disqus/types/post'

module Events
  module Disqus

    class Processor
      def process(original_hash, processed)
        processed.deep_merge({
          meta: {
            feed: 'disqus',
            type: 'post',
          }
        })
      end
      
      def determine_event_type(original_hash)
        "Post"
      end

      def events_from_response(response)
        response['response']
      end
    end

  end
end
