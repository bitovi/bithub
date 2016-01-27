require_relative 'base_fetcher'

module Guzzler::Fetchers

  module Facebook
    class Search < BaseFetcher

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
