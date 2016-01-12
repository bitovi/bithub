require 'celluloid/current'
require 'celluloid/autostart'

require 'guzzler/listener/registry'
require 'guzzler/listener/subscriber'
require 'guzzler/listener/http_server'

module Guzzler
  module Listener

    class Runner
      include Celluloid
      include Util

      def initialize
        @condvar = Celluloid::Condition.new

        @registry = Guzzler::Listener::Registry.new_link
        @http_server = Guzzler::Listener::HttpServer.new_link({ host: '0.0.0.0' })
        @subscriber = Guzzler::Listener::Subscriber.new_link(@registry, @condvar)
        @done = false
      end

      def run
        watchdog('Listener#run') do
          @http_server.start
          @subscriber.subscribe
          @subscriber.preload_items
        end
      end

      def stop
        watchdog('Listener#stop') do
          @done = true
          @subscriber.async.unsubscribe
          @condvar.wait
          @subscriber.terminate
          @http_server.terminate
        end
      end
    end
  end
end
