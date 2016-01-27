require_relative 'common'

module Guzzler::Fetchers

  module Tumblr
    class Tagged
      include Protocol
      include Tumblr::Common

      # http://www.tumblr.com/docs/en/api/v2#tagged-method
      
      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          @result = client.tagged tag
        end
      end

      def tag
        @service.config.fetch(:tag)
      end
    end
  end
end
