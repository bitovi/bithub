module Entities
  module Facebook

    class Status < Protocol
      include Facebook::SharedBuilders

      def find
        @event.status.id && find_by_status_id.first
      end

      def find_by_status_id
        Entity
        .feed('facebook')
        .type('status')
        .where(origin_id: @event.status.id.to_s)
      end

      def data
        with_commons({})
      end

      def build
        Entity.new(data)
      end
      
      def update
        @instance.props[:origin_author_name] = @event.from.name
      end

      def build_children
        build_comments.to_a
      end

      def build_comments
        @event.comments.map do |c| # Build entities
          Entities::Facebook::Comment.new(@event, c)
          .procure.determine.group.normalize.instance
        end if @event.comments
      end

    end
  end
end
