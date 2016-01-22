require 'koala'

module Handlers
  module Facebook

    class Subscriptions

      def initialize(proxy, opts = {})
        @proxy = proxy
        opts.fetch(:condvar).signal
      end

      def handle(req)
        handle_subscription req
      end

      def self.route
        ['GET', '/facebook/page/feed']
      end

      private

      def handle_subscription(req)
        err_resp = [403, ':p']
        return err_resp unless req.query_string

        params    = CGI::parse req.query_string
        challenge = params['hub.challenge'].first
        token     = params['hub.verify_token'].first

        if token == ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
          [200, challenge]
        else
          err_resp
        end
      end

    end

  end
end
