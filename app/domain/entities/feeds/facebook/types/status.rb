module Entities
  module Facebook

    class Status < Protocol

      def find
        @event.status.id && find_by_status_id.first
      end
      
      def find_by_issue_id
        Entity
        .feed('facebook')
        .type('status')
        .where(origin_id: @event.status.id.to_s)
      end

      def build
        built = Entity.new({
          title: title,
          body: @event.message,
          url: @event.link,
          origin_id: @event.id,
          origin_ts: @event.created_time,
          props: {
            origin_author_id: @event.poster.id,
            origin_author_name: @event.poster.name,
          }
        })

        built
      end

      private

      def title
        "#{@event.poster.name} posted: #{@event.type}"
      end

    end

  end
end
