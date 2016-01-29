require 'entities/protocol'
require_relative 'shared'

module Entities
  module Facebook

    class Link < Protocol
      include Facebook::Shared

      def find
        @event.link_obj.id && find_by_link_id.first
      end

      def find_by_link_id
        Entity
        .feed('facebook')
        .type('link')
        .where(origin_id: @event.link_obj.id.to_s)
      end

      def data
        tmp = with_commons({
          props: {
            photos: JSON.generate(@event.link_obj.images)
          }
        })

        tmp[:title] = @event.message
        tmp[:body] = @event.description
        tmp
      end

      def update
        @instance.props[:origin_author_name] = @event.from.name
      end

    end
  end
end
