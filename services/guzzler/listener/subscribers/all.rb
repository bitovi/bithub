module Guzzler::Listener::Subscribers

  class BaseSubscriber
    def initialize(registry, service)
      @registry = registry
      @service = service
    end
    attr_reader :service
  end

  class NullSubscriber
    def initialize
      Guzzler.logger.warn "No subscriber class matching service: #{service.inspect}"
    end
    def subscribe; end
    def unsubscribe; end
  end
end

require 'subscribers/instagram'
require 'subscribers/facebook'
require 'subscribers/foursquare'
