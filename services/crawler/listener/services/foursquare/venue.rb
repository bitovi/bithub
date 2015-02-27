module Supervisors::Services::Foursquare
  class Venue < Supervisors::Service

    def initialize
      super
      info "Creating Foursquare #{self.class} subscription #{@path.brand.name}->#{@path.embed.name} with #{service_config}"
      venues_handler.register venue_id, @path.serialize
    end

    private

    def venue_id
      service_config.fetch(:id)
    end

    def venues_handler
      Celluloid::Actor[:http_server_foursquare_venues]
    end

  end
end
