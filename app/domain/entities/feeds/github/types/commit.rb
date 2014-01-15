module Entities
  module Github

    class Commit
      include Entities::Constructable

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def procure
        commits = @payload.commits && find_by_multiple_commit_shas.all
        if commits.empty?
          build_many_from_push
        else
          commits
        end
      end

      def procure_parent
      end

      def procure_children
      end

      def procure_references
      end

      def build_many_from_push
        @payload.commits.map do |commit|
          #Do stuff
          commit
        end
      end

      def find_by_multiple_commit_shas
        @persistor.tagged_with(['github', 'commit'])
        .where("position(props -> 'commit_sha' in '#{@payload.commit_shas_csv}') > 0")
      end
    end

  end
end
