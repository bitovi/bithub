module Guzzler
  module Listener
    module Handlers

      class Handler
        def initialize(registry, opts = {})
          @registry = registry
        end


        def handle(req)
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
