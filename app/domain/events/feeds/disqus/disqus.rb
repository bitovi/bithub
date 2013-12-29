require 'events/feeds/disqus/types/post'

module Events
  module Disqus

    class Processor
      def process(original_hash, processed)
        processed.deep_merge({
          extracted: {
            title: original_hash['thread']['title'],
            body: original_hash['message'],
            url: original_hash['url'],
          },
          meta: {
            feed: 'disqus',
            type: 'post',
            post_id: original_hash['id'],
            origin_author_name: original_hash['author']['name'],
          }
        })
      end

      def origin_timestamp(original_hash)
        # Disqus provides date in format: "2013-02-14T22:47:29" !!! we append 'Z'
        Time.parse(datetime_str(original_hash)+"Z").utc
      end

      def content_digest(original_hash)
        seed = ((original_hash[:id] || original_hash['id']).to_s + 'disqus')
        Digest::MD5.hexdigest(seed)
      end

      def events_from_response(response)
        response['response']
      end

      private

      def datetime_str(original_hash)
        (str = original_hash['createdAt']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
      end
    end

  end
end
