module Entities
  module Github

    class Watch < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: "started watching #{@event.repo.name}",
          origin_ts: @event.created_at,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            repo_name: @event.repo.name,
          }
        })
      end
    end

  end
end
