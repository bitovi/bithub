module Fetchers
  module Twitter

    class TweetSearch
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @interval = opts.fetch(:interval) { 10 }
        @terms = opts.fetch(:terms).join(' OR ')
      end
      attr_reader :interval
      
      def fetch
        @client.search(@terms, :count => 100).take(100)
      end
    end
  end
end
