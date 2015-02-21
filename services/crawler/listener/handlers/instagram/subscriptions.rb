module Handlers
  module Instagram

    class Subscriptions

      def initialize(proxy)
        @proxy = proxy
      end

      def handle(req)
        params =  CGI::parse req.query_string
        [200, params['hub.challenge'].first]
      end

      def self.route
        ['GET', '/instagram/media']
      end

    end

  end
end
