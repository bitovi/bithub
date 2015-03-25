module Identities
  module Facades
    class Facebook < Facade::Protocol
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

      def pages
        @extracted_data[:pages] || []
      end
    end
  end
end
