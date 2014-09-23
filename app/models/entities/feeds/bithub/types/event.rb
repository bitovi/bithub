module Entities
  module Bithub
    class Event < Post

      def build
        entity = super
        entity.props[:scheduled_at] = @event.scheduled_at
        entity.origin_ts = @event.scheduled_at
        entity
      end

    end
  end
end
