module Entities
  module Github

    class Watch < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def find
        nil
      end

      def build
        Rails.logger.info "KURCA BUILDAM GITHUB"
        Entity.new({
          title: "started watching #{@payload.repo_name}",
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            repo_name: @payload.repo_name,
          }
        })
      end

      def relationships
        Entities::Github::Watch::Relationships
      end
    end

  end
end
