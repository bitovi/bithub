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
        Entity.new({
          title: "pushed to #{@payload.repo_name}",
          body: @commit.andand[:message],
          url: @commit.andand[:url],
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            repo_name: @payload.repo_name,
            sha: @commit.andand[:sha],
          }, # set next manually b/c AR will call save instead of persist on children
          feed_name: feed_name.snake_case,
          type_name: type_name.snake_case,
        })
      end

      # override Referencable
      def references_in_content
        @commit[:message].scan(/#\d+/).map {|m| m.gsub('#','').to_s}
      end

      private

      def find_by_commit_sha
        Entity.tagged_with(['github', 'commit'])
          .where("props -> 'sha' = '#{@commit[:sha]}'")
      end
    end

  end
end
