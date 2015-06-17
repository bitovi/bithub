require 'entities/protocol'
require_relative 'shared'

module Entities
  module Twitter

    class Follow < Protocol
      include Shared

      POLLER_INTERVAL = 600

      def find
        nil
      end

      def data
        with_commons({
          title: "followed user #{@event.target.id}",
          origin_ts: fake_origin_ts,
          is_pending: true,
          props: {
            target_id: @event.target.id,
            target_name: @event.target.screen_name,
          }
        })
      end

      private

      def fake_origin_ts
        last_follow = Entity\
          .feed('twitter')
          .type('follow')
          .target_id(@event.target.id.to_s)
          .last

        # First follow in first batch
        if !last_follow
          10.years.ago

        # Still in current batch
        elsif Time.now - last_follow.created_at <= POLLER_INTERVAL/2
          last_follow.origin_ts

        # Starting a new batch
        else
          Time.now
        end
      end

    end
  end
end
