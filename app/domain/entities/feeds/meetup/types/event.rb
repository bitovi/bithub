module Entities
  module Meetup

    class Event
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance

      def procure
        @instance = (@payload.event_id && (e = find_by_event_id.first)) ? e : build
        self
      end

      def procure_parent
      end

      def procure_children
      end

      def procure_references
      end

      def build
        e = Entity.new({
          title: @payload.name,
          body: @payload.description,
          url: @payload.url,
          origin_ts: @payload.origin_timestamp,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            event_id: @payload.event_id,
          }
        })
        e.props.symbolize_keys!
        e
      end

      def find_by_event_id
        Entity.tagged_with(['meetup', 'event'])
        .where("props -> 'event_id' = '#{@payload.event_id}'")
      end

    end

  end
end
