module Events
  module Blog

    class Processor
      def process(original_hash, processed)
        fail_if_invalid(original_hash)

        processed.deep_merge({
          extracted: {
            title: original_hash['title'],
            url: original_hash['link'],
            body: Sanitize.clean(original_hash['description'], Sanitize::Config::RELAXED),
          },
          meta: {
            feed: 'blog',
            type: 'post',
          }
        })
      end

      def origin_timestamps(original_hash)
        Time.strptime(datetime_str(original_hash), "%e %b %Y").utc
      end

      def content_digest(event_hash)
        seed = ((event_hash[:link] || event_hash['link']) + 'blog')
        Digest::MD5.hexdigest(seed)
      end

      def events_from_response(response)
        response['rss']['channel']['item']
      end

      private

      def fail_if_invalid(original_hash)
        fail Processor::InvalidEventException, "not a valid blog post" if not(valid_post?(original_hash))
      end

      def valid_post?(original_hash)
        has_title?(original_hash) && has_body?(original_hash) && has_url?(original_hash)
      end

      def has_title?(original_hash)
        !!original_hash['title']
      end

      def has_body?(original_hash)
        !!original_hash['description']
      end

      def has_url?(original_hash)
        !!original_hash['link']
      end

      def datetime_str(original_hash)
        (str = original_hash['published']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
      end
    end

  end
end
