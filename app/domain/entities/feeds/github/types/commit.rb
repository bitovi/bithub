module Entities
  module Github

    class Commit
      include Entities::Constructable
      include Entities::Determinable
      
      attr_reader :instance

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def procure
        if commit = @payload.sha && find_by_commit_sha
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
        @persistor.new({
          title: @payload.message,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            sha: @payload.sha
          }
        });
      end

      private

      def build_many_from_push
        @payload.commits.map do |commit|
          #Do stuff
          commit
        end
      end

      def find_by_commit_sha
        Entity.tagged_with(['github', 'commit'])
          .where("props -> 'sha' = '#{@payload.sha}'")
          .first
      end
    end

  end
end
