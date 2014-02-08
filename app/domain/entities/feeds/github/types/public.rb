module Entities
  module Github

    class Public < Protocol
      include Events::Github::Accessors::Standard

      def find
        nil
      end

      def build
        Entity.new({
          title: title,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.public_id.to_s,
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
        "repository #{@payload.repo_name} goes public"
      end
    end

  end
end
