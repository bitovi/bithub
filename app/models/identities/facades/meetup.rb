module Identities
  module Facades
    class Meetup < Facade::Protocol

      def property_id_name_pairs
        group_ids_and_names
      end

      def group_name_for_id(group_id)
        groups.find do |g|
          g['id'].to_s == group_id.to_s
        end['name']
      end

      def group_ids_and_names
        groups.map do |g|
          { id: g['id'], name: g['urlname'] }
        end
      end

      def groups
        @extracted_data[:groups] || []
      end
    end
  end
end
