module Identities
  module Facades
    class Disqus < Facade::Protocol

      def property_id_name_pairs
        forum_ids_and_names
      end

      def forum_ids_and_names
        forums.map do |f|
          { id: f['id'], name: f['name'] }
        end
      end

      def forums
        @extracted_data[:forums] || []
      end
    end
  end
end
