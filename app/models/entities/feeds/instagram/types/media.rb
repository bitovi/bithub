module Entities
  module Instagram

    class Media < Protocol

      def find
        @event.id && find_by_instagram_id.first
      end

      def build
        Entity.new({
          title: "Instagram media",
          url: @event.link,
          origin_ts: @event.created_at,
          origin_id: @event.id,
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.full_name,
            origin_author_avatar_url: @event.user.profile_picture,
            caption: caption,
            image_url: image_url
          }
        })
      end

      def caption
        @event.source_data[:caption].andand[:text] || ''
      end

      def image_url
        @event.source_data[:images].andand[:standard_resolution].andand[:url]
      end

      # Finders
      def find_by_instagram_id
        Entity
        .feed('instagram')
        .type('media')
        .where(origin_id: @event.id)
      end

    end

  end
end
