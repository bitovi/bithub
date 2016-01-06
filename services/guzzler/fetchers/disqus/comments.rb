require 'httparty'

module Guzzler::Fetchers
  module Disqus
    class Comments
      include Protocol

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        handle_errors do
          resp = HTTParty.get url, :query => related.merge(forum).merge(auth)
          pluck(resp)
        end
      end

      private

      def pluck(response)
        response['response'] || []
      end

      def forum
        { :forum => @job.config.fetch('url') }
      end

      def related
        { :related => %w(thread forum) }
      end

      def url
        'http://disqus.com/api/3.0/posts/list.json'
      end

      def auth
        { :api_key => Guzzler.static_config.fetch(:disqus).fetch(:api_key) }
      end
    end
  end
end
