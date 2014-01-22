module Entities
  module Github

    class Commit < Protocol

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def initialize(payload, sha)
        @payload = payload
        @commit = @payload.commit_by_sha(sha)
      end

      def procure
        if commit = @payload.commits && find_by_commit_sha
          @instance = commit
        else
          @instance = build
        end
        self
      end

      def procure_parent
      end

      def procure_children
      end

      def procure_references
      end

      def build
        Entity.new({
          title: "pushed to #{@payload.repo_name}",
          body: @commit.andand[:message],
          url: @commit.andand[:url],
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: 'commit',
            repo_name: @payload.repo_name,
            sha: @commit.andand[:sha],
            push_id: @payload.push_id,
          }
        });
      end

      private

      def find_by_commit_sha
        Entity.tagged_with(['github', 'commit'])
          .where("props -> 'sha' = '#{@commit[:sha]}'")
          .first
      end
    end

  end
end
