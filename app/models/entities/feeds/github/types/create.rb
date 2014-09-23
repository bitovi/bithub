module Entities
  module Github

    class Create < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: title,
          origin_ts: @event.created_at,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
          }
        })
      end

      private

      def title
        "created a new #{@event.ref_type} on #{@event.repo.name}: #{@event.ref}"
      end
    end

  end
end
