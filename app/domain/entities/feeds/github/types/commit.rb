module Entities
  module Github
    module Commit

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          # how to find from push?
        end
        
        def build(payload)
          # how to build from push?
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
