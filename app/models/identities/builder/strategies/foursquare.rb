module Identities
  class Builder
    module Strategies
      class Foursquare < Identities::Builder::Protocol

        def fetch_venues
          if (venues = venues_over_http)
            @result[:venues] = venues
          end
        end

        private
        def venues_over_http
          client.managed_venues.items
        end

        def client
          Foursquare2::Client.new(
            api_version: '20141111',
            oauth_token: @source_data.fetch(:credentials).fetch(:token)
          )
        end
      end
    end
  end
end
