module Entities
  module Github
    module Commit

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [Entities::Github::CommitComment]
      }

      class Procurer < Entities::Procurer
        include Entities::Github::Accessors

        def find_self(payload)
          # how to find from push?
        end
        
        def build_self(payload)
          # build from push
        end

        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github', 'commit'])
            .where("props -> 'commit_sha' = '#{commit_sha}'")
            .first
        end

        def relationships
          Entities::Github::Commit::Relationships
        end
      end

    end
  end
end
