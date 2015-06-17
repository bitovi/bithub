module Entities
  module Stackexchange

    module Shared

      def base_attributes
        {
          body: @event.body_markdown,
          url: @event.link,
          origin_ts: @event.creation_date,
          searchable_author: @event.owner.name
        }
      end

      def origin_author_data
        { 
          props: {
            origin_author_id: @event.owner.id,
            origin_author_name: @event.owner.name,
            origin_author_avatar_url: @event.owner.profile_image,
          }
        }
      end

      def with_commons(data)
        data
          .merge(base_attributes)
          .deep_merge(origin_author_data)
      end

    end
  end
end
