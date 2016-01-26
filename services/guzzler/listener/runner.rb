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
        @http_server = Guzzler::Listener::HttpServer.new_link(@registry)
        @subscriber = Guzzler::Listener::Subscriber.new_link(@registry, @http_server)
        @done = false
      end

      def run
        watchdog('Listener#run') do
          @http_server.async.start
          @subscriber.async.start
        end
      end

      def stop
        watchdog('Listener#stop') do
          @done = true
          @subscriber.async.unsubscribe
          @condvar.wait
          @subscriber.terminate
          @http_server.terminate
          @registry.terminate
        end
      end
    end
  end
end
