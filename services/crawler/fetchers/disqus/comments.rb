require 'httparty'

module Fetchers
  module Disqus

    class Comments
      include Protocol

      def initialize(opts)
        @forums = opts.fetch(:forums)
        @token = opts.fetch(:token)
        @api_key = opts.fetch(:api_key) { |key|  }
      end
      attr_readed :token

      def fetch
        HTTParty.get url, :query => related.merge(forums)
      end

      private

      def forums
        { :forums => @forums }
      end

      def related
        @related ||= { :related: %w(thread forum) }
      end

      def url
        @url ||= 'http://disqus.com/api/3.0/posts/list.json'
      end

      def auth
        @auth ||= {
          :access_token => 'dskfjs',
          :api_key => 
      end

    end
  end
end

