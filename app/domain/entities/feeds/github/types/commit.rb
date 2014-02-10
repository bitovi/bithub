module Entities
  module Github

    class Commit < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def initialize(payload, sha)
        @payload = payload
        @commit = @payload.commit_by_sha(sha)
      end

      def find
        @commit.andand[:sha] && find_by_commit_sha.first
      end

      def build
        built = Entity.new({
          title: "pushed to #{@payload.repo_name}",
          body: @commit.andand[:message],
          url: @commit.andand[:url],
          origin_ts: @payload.origin_ts,
          origin_id: @commit.andand[:sha],
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            origin_author_avatar_url: @payload.actor_avatar_url,
            repo_name: @payload.repo_name,
            sha: @commit.andand[:sha],
          }, # set next manually b/c AR will call save instead of persist on children
          feed_name: feed_name.snake_case,
          type_name: type_name.snake_case,
        })

        built.props[:references_to] = references_in_content_csv unless references_in_content_csv.blank?

        built 
      end

      # override Referencable
      def references_in_content
        @commit[:message].scan(/#\d+/).map {|m| m.gsub('#','').to_s}
      end

      def references_in_content_csv
        references_in_content.join(',')
      end

      private

      def find_by_commit_sha
        Entity
        .feed('github')
        .type('commit')
        .where(origin_id: @commit[:sha])
      end
    end

  end
end
