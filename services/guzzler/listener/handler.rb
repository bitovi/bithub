module Guzzler
  module Listener
    module Handlers

      class Handler
        def initialize(registry, opts = {})
          @registry = registry
        end

        def publish(events, service)
          Guzzler.processing_chain.invoke(events, service).each do |event|
            Guzzler.lpush('event_q', event)
          end
        end

        def handle_errors
          yield

        rescue Guzzler::SubscriptionError => e
          # TODO
        rescue Guzzler::FetchError => e
          # TODO
        end
      end

    end
  end
end

require 'handlers/facebook'
require 'handlers/instagram'
require 'handlers/foursquare'
