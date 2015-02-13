module Entities
  module Services

    class FacebookPhotoSourceFiller

      def initialize(service, client)
        @service = service
        @client = client
      end

      def fill
        @service.entities.each do |e|
          photo = fetch_photo_by_object_id e.props['origin_object_id']
          fill_photo_source e, photo
        end
      end

      private

      def fetch_photo_by_object_id(object_id)
        @client.get_object object_id
      end

      def fill_photo_source(entity, photo_object)
        entity.props['image_url'] = photo_object['source']
        entity.is_pending         = false

        entity.props_will_change!
        entity.save!
      end

    end
  end
end
