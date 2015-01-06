require 'twitter'

module Fetchers
  module Twitter

    class Hashtags
      include Protocol

      def initialize(client, opts)
        @client = client
        @hashtags = opts.fetch(:hashtags)
      end

      def hashtags=(new_hashtags)
        @hashtags = new_hashtags
      end
      
      def fetch
        @client.search(@hashtags.join(' '), :count => 100).take(100)
      end
    end
  end
end
