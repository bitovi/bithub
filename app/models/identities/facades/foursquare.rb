module Identities
  module Facades
    class Foursquare < Facade::Protocol

      def property_id_name_pairs(type=nil)
        venue_ids_and_names
      end

      def venue_ids_and_names
        venues.map do |v|
          { id: v['id'], name: v['name'] }
        end
      end

      def venue_name_for_id(venue_id)
        venues.find do |v|
          v['id'].to_s == venue_id.to_s
        end['name']
      end

      def venues
        @extracted_data[:venues] || []
      end
    end
  end
end
