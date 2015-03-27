require 'twitter'

module Fetchers
  module Twitter

    class Search
      include Protocol

      def initialize(client, opts)
        @client = client
        @term = opts.fetch(:term)
      end
      
      def fetch
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Twitter/search')
        handle_errors do
          @client.search(@term, :count => 100).take(100)
        end
      end
    end
  end
end
