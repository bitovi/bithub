module Entities
  module Bithub
    class Event < Post

      def build

        entity = super
        entity.props[:scheduled_at] = @payload.scheduled_at
        entity.origin_ts = @payload.scheduled_at

        entity

      end

    end
  end
end
