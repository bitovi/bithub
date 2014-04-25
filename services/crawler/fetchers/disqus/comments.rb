require 'httparty'

module Fetchers
  module Disqus

    class Comments
      include Protocol

      def initialize(opts)
        @forums = opts.fetch(:forums)
        @api_key = opts.fetch(:api_key)
      end

      def fetch
        HTTParty.get url, :query => related.merge(forums).merge(auth)
      end

      private

      def forums
        { :forums => @forums }
      end

      def related
        { :related: %w(thread forum) }
      end

      def url
        'http://disqus.com/api/3.0/posts/list.json'
      end

      def auth
        { :api_key => @api_key }
      end

    end
  end
end

