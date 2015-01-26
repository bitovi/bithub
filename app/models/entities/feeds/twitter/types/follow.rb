module Entities
  module Twitter

    class Follow < Protocol
      POLLER_INTERVAL = 10.minutes

      def find
        nil
      end

      def build
        last_follow = Entity\
          .where(feed_name: 'twitter', type_name: 'follow')\
          .where("props -> 'target_id' = :target_id", target_id: @event.target.id.to_s)\
          .last

        if !last_follow # First follow in first batch
          origin_ts = 10.years.ago
        elsif Time.now - last_follow.created_at <= POLLER_INTERVAL/2 # Still in current batch
          origin_ts = last_follow.origin_ts
        else # Starting a new batch
          origin_ts = Time.now
        end

        Entity.new({
          title: "followed user #{@event.target.id}",
          origin_ts: origin_ts,
          props: {
            origin_author_id: @event.source.id.to_s,
            origin_author_name: @event.source.screen_name,
            target_id: @event.target.id,
            target_name: @event.target.screen_name,
          }
        })
      end

    end
  end
end
