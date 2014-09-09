module FeedSupervisors
  class Foursquare
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting Foursquare supervisor for #{@brand_name}"

      venues_handler.register @brand_name, venue_ids
    end

    private

    def venues
      Celluloid::Actor[:configurator].feed_config(@brand_name, :foursquare).fetch(:venues)
    end

    def venue_ids
      venues.map {|v| v.fetch(:id)}
    end

    def venues_handler
      Celluloid::Actor[:http_server_foursquare_venues]
    end

  end
end
