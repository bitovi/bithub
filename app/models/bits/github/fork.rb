require 'bits/protocol'
require_relative 'shared'

module Bits
  module Github

    class Fork < Protocol
      include Shared

      def find
        @event.event_id && find_by_actor_and_repo_name.first
      end

      def data
        with_commons({
          title: "forked #{@event.repo.name}",
          origin_id: @event.fork_id.to_s,
        })
      end

      def find_by_origin_id
        Bit
          .feed('github')
          .type('fork')
          .where(origin_id: @event.fork_id.to_s)
      end

      def find_by_actor_and_repo_name
        Bit
          .feed('github')
          .type('fork')
          .origin_author(@event.actor.id)
          .repo_name(@event.repo.name)
      end
    end
  end
end
