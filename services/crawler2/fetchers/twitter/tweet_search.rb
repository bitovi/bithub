require_relative 'client'

module Fetchers
  module Twitter

    class TweetSearch
      include Client
      
      def fetch
        @terms = @config.fetch(:terms).join(',')
        @client.search(terms, :result_type => "recent").take(10).to_a
      end
    end

  end
end
