module Guzzler::Listener::Subscribers
  class FoursquareVenue < BaseSubscriber
    
    def subscribe
      @registry.subscribe 'foursquare', 'venue', venue_id, @service
    end

    def unsubscribe
      @registry.unsubscribe 'foursquare', 'venue', venue_id, @service
    end

    private

    def venue_id
      @service.config.fetch(:id)
    end
  end
end
