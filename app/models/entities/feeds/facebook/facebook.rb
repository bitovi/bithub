module Entities
  module Facebook

    module SharedBuilders

      def base_attributes
        {
          title: "#{@event.from.name} posted: #{@event.type}",
          body: @event.message,
          url: @event.link,
        }
      end

      def author_meta_attribute
        { author: @event.from.name }
      end

      def origin_data
        {
          origin_id: @event.id,
          origin_ts: @event.created_time,
        }
      end
     
      def props_origin_author_data
        {
          props: {
            origin_author_id: @event.from.id,
            origin_author_name: @event.from.name
          }
        }
      end

      def with_commons(data)
        data
          .deep_merge(base_attributes)
          .deep_merge(origin_data)
          .deep_merge(props_origin_author_data)
      end
    end

    class Status < Protocol; end
    class Photo < Protocol; end
  end
end

require_relative 'types/status'
require_relative 'types/photo'
