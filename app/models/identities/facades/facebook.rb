module Identities
  module Facades
    class Facebook < Facade::Protocol

      def credentials(page_id)
        access_token = page_token(page_id) || user_long_lived_token

        { access_token: access_token }
      end

      def property_id_name_pairs(type=nil)
        page_ids_and_names
      end

      def page_ids_and_names
        pages.map do |p|
          { id: p['id'], name: p['name'] }
        end
      end

      def page_name_for_id(page_id)
        pages.find do |p|
          p['id'].to_s == page_id.to_s
        end['name']
      end

      def page_token(page_id)
        if (page = pages.select{|p| p.fetch('id') == page_id}.first)
          page.fetch('access_token')
        end
      end

      def user_long_lived_token
        @extracted_data.fetch :long_lived_access_token
      end

      def pages
        @extracted_data[:pages] || []
      end
    end
  end
end
