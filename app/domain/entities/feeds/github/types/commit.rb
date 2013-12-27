module Entities
  module Github
    module Commit

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [Entities::Github::CommitComment]
      }

      class Procurer < Entities::Procurer

        def find(payload)
          # how to find from push?
        end

        def build(payload)
          if type(payload) == 'Push'
            build_from_push
          else
            fail Entities::Errors::BuildingException, "don't know how  build the entity from supplied payload"
          end
        end

        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github', 'commit'])
            .where("props -> 'commit_sha' = '#{commit_sha}'")
        end
        
        def build_from_push
          ["COMMIT1", "COMMIT2"]
        end
      end

    end
  end
end
