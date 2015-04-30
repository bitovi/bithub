module Entities
  module Instagram

    class Media < Protocol

      def find
        @event.id && find_by_instagram_id.first
      end

      def data
        {
          title: caption,
          url: @event.link,
          origin_ts: @event.created_at,
          origin_id: @event.id,
          author: (@event.user.username + ' ' + @event.user.full_name).trim,
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.username,
            origin_author_avatar_url: @event.user.profile_picture,
            image_url: image_url
          }
        }
      end

      def update
        @instance.props[:origin_author_name] = @event.user.full_name
        @instance.props[:origin_author_username] = @event.user.username
        self
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
