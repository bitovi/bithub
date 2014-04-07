module HttpHandlers
  module Foursquare
    class Venues
      include Protocol

      def handle
        respond body: "Handling FourSquare Vanue"
      end
    end
  end
end
