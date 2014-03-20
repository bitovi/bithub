require_relative 'client'

module Fetchers
  module Twitter

    class TweetSearch
      include Client
      
      def initialize(cfg)
        super(cfg)
        @terms = @config.fetch(:terms).join(',')
      end

      def fetch
        @client.search(terms, :result_type => "recent").take(10).to_a
      end
    end

  end
end
