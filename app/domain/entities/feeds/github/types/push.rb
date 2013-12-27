module Entities
  module Github
    module Push

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::Commit, Entities::Github::CommitComment]
      }

      class Procurer < Entities::Procurer

        def find(payload)
          if push_id(payload)
            find_by_push_id(push_id(payload))
          end
        end

        def build(payload)
          build_from_push(payload)
        end
        
        def find_by_push_id(push_id)
          @p.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{push_id}'")
        end

        def build_from_push
          "PUSH"
        end
      end

    end
  end
end
