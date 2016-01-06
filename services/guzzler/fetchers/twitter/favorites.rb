require_relative 'common'

module Guzzler::Fetchers

  module Twitter
    class Favorites
      include Protocol
      include Twitter::Common

      def initialize(job)
        @job = job
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
