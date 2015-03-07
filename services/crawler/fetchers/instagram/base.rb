require 'instagram'

module Fetchers
  module Instagram

    class Base

      COUNT = 100

      attr_reader :result, :client, :count

      def initialize(object_id, opts={})
        @client    = create_client
        @object_id = object_id
        @count     = opts[:count] || COUNT

        # user_id or access_token
      end

      def fetch(opts={})
        opts[:count] ||= @count

        handle_errors do
          @result = fetch_once opts
        end
      end

      def has_next?
        @result && @result.pagination.andand("next_max_id")
      end

      def next
        if next_max_id = has_next?
          @result = fetch max_id: next_max_id
        end
      end

      def reset
        @result = nil
      end

      def self.fetch(object_id, opts={})
        self.new(object_id, opts).fetch
      end

      private

      def create_client
        ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
      end

      def log_error(meta)
        Celluloid.logger.info " #{meta.code}: #{meta.error_type} #{meta.error_message}"
      end

      def publisher
        Celluloid::Actor[:event_publisher]
      end

    end

  end
end
