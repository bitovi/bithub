module Entities
  module Github

    class Watch < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: "started watching #{@payload.repo_name}",
          origin_ts: @payload.created_at,
          props: {
            origin_author_id: @payload.actor.id,
            origin_author_name: @payload.actor.login,
            repo_name: @payload.repo.name,
          }
        })
      end
    end

  end
end
