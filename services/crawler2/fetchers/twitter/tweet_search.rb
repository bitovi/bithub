require_relative 'client'

module Fetchers
  module Twitter

    class TweetSearch
      include Client
      
      def fetch
        @terms = @config.fetch(:terms).join(' OR ')
        @client.search(@terms, :count => 100).take(100)
      end
    end

  end
end
