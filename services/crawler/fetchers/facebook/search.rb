require_relative 'base'

module Fetchers
  module Facebook
    class Search < Base

      def fetch(term, opts={})
        type = opts[:type] || 'page'

        handle_errors do
          @client.search term, type: type
        end
      end

    end
  end
end
