require_relative 'base'

module Guzzler::Fetchers

  module Facebook
    class Search < Base

      def fetch(term, opts={})
        log_fetch

        type = opts[:type] || 'page'

        handle_errors do
          @client.search term, type: type
        end
      end

    end
  end
end
