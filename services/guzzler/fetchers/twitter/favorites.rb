require_relative 'common'

module Guzzler::Fetchers

  module Twitter
    class Favorites
      include Protocol
      include Twitter::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch
        handle_errors do
          client.favorites(handle, :count => count)
        end
      end
    end
  end
end
