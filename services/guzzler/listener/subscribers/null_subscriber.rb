module Guzzler::Listener::Subscribers
  class NullSubscriber
    def initialize
      Guzzler.logger.warn "No subscriber class matching service: #{service.inspect}"
    end
    def subscribe; end
    def unsubscribe; end
  end
end
