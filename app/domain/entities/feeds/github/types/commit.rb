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
            fill_props(build_from_push(payload), payload)
          else
            build_fail
          end
        end

        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github', 'commit'])
            .where("props -> 'commit_sha' = '#{commit_sha}'")
            .first
        end
        
        def build_from_push(payload)
          @p.new(extracted(payload))
        end
      end

    end
  end
end
