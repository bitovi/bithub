module Guzzler::Listener::Subscribers
  class BaseSubscriber
    def initialize(registry, service)
      @registry = registry
      @service = service
    end
    attr_reader :service
  end
end
