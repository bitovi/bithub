require 'instagram'

module Guzzler::Fetchers

  module Instagram
    class Base
      include Protocol

      COUNT = 100

      attr_reader :result, :client, :count

      def initialize(object_id, opts={})
        @object_id    = object_id
        @count        = opts[:count] || COUNT
        @access_token = opts[:access_token]
        @client       = create_client
      end

      def fetch
        opts = { count: @count }
        agg_results = []

        # initial fetch
        handle_errors do
          @result = fetch_once opts
        end
        agg_results += @result.to_ary

        # iterate
        while agg_results.count < @count && has_more?
          handle_errors do
            @result = fetch_once opts.merge({max_id: has_more?})
          end
          agg_results += @result.to_ary
        end

        agg_results
      end

      def has_more?
        @result && @result.pagination.andand("next_max_id")
      end

      def load_more
        if next_max_id = has_more?
          opts = { max_id: next_max_id, count: @count }
          @result = fetch opts
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
        if @access_token
          ::Instagram.client access_token: @access_token
        else
          ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
        end
      end

      def log_error(meta)
        Celluloid.logger.info " #{meta.code}: #{meta.error_type} #{meta.error_message}"
      end

    end

  end
end
