require 'events/feeds/twitter/types/tweet'
require 'events/feeds/twitter/types/follow'

module Events
  module Twitter
    MAPPINGS = {
      'StatusEvent' => 'Tweet'
    }

    def self.type(type_name)
      if MAPPINGS && MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.const_get(type_name)
      end
    end

    class Processor
      attr_reader :parsed, :extracted

      def initialize
        config = {}
        @config = yield config if block_given?
      end

      def process(original_hash, partly_processed_hash)
        fail_if_invalid(original_hash)

        partly_processed_hash = partly_processed_hash
        .deep_merge({ meta: { feed: 'twitter' }})

        if is_user_stream? && is_follow_event?(original_hash)
          prepare_event_from_user_stream(original_hash, partly_processed_hash)
        elsif is_public_stream? && is_status_event?(original_hash)
          prepare_event_from_public_stream(original_hash, partly_processed_hash)
        end
      end

      def origin_timestamp(original_hash)
        fail_if_invalid(original_hash)
        Time.parse(datetime_str(original_hash)).utc
      end

      def unique_attribute(original_hash)
        (original_hash[:id] || original_hash['id']).to_s
      end

      private

      def datetime_str(original_hash)
        (str = original_hash['created_at']) ? str : (fail Events::Errors::MissingTimestamp, "missing origin timestamps");
      end

      def fail_if_invalid(original_hash)
        fail Events::Errors::InvalidEventException, "not a follow_event nor a status_event" if not(follow_or_status?(original_hash))
      end

      def follow_or_status?(event_hash)
        (is_follow_event?(event_hash) && not(we_are_source?(event_hash))) || is_status_event?(event_hash)
      end

      def is_user_stream?
        @config['user_stream_flag'] || false
      end
      
      def is_public_stream?
        not(@user_stream_flag)
      end

      def we_are_source?(event_hash)
        %w(bitovi canjs javascriptmvc jquerypp stealjs funcunit bitovi_bithub).include? event_hash['source']['screen_name']
      end

      def is_follow_event?(event_hash)
        (event_hash['event'].andand == 'follow') &&
          has_timestamp?(event_hash) &&
          has_target_screen_name?(event_hash)
      end

      def is_status_event?(event_hash)
        event_hash['text'] &&
          has_timestamp?(event_hash) &&
          has_user?(event_hash)
      end

      def has_target_screen_name?(event_hash)
        !!event_hash['target']['screen_name']
      end

      def has_timestamp?(event_hash)
        !!event_hash['created_at']
      end

      def has_user?(event_hash)
        event_hash['user'] && event_hash['user']['screen_name']
      end

    end
  end
end
