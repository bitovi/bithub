module Entities
  module Github

    class Create < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: title,
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            origin_author_avatar_url: @payload.actor_avatar_url,
            repo_name: @payload.repo_name,
          }
        })
      end

      private

      def title
        "created a new #{@payload.ref_type} on #{@payload.repo_name}: #{@payload.ref}"
      end
    end

  end
end
