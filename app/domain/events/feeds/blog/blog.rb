require 'events/feeds/blog/types/post'

module Events
  module Blog

    class Processor
      def process(original_hash, processed)
        processed.deep_merge({
          meta: {
            feed: 'blog',
            type: 'post',
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
