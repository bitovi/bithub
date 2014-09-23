module Entities
  module Github

    class Fork < Protocol

      def find
        @event.event_id && find_by_actor_and_repo_name.first
      end

      def build
        Entity.new({
          title: "forked #{@event.repo.name}",
          origin_ts: @event.created_at,
          origin_id: @event.fork_id.to_s,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
          }
        })
      end

      def find_by_origin_id
        Entity
        .feed('github')
        .type('fork')
        .where(origin_id: @event.fork_id.to_s)
      end

      def find_by_actor_and_repo_name
        Entity
        .feed('github')
        .type('fork')
        .where("props -> 'origin_author_id' = '#{@event.actor.id}'")
        .where("props -> 'repo_name' = '#{@event.repo.name}'")
      end

    end

  end
end
