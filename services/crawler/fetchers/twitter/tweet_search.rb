require 'twitter'

module Fetchers
  module Twitter

    class TweetSearch
      include Protocol

      def initialize(client, opts)
        @client = client
        @terms = opts.fetch(:terms)
      end

      def set_terms(new_terms)
        @terms = new_terms
      end
      
      def fetch
        @client.search(@terms.join(' OR '), :count => 100).take(100)
      end
    end
  end
end
