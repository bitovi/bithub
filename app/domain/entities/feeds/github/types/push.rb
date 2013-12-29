module Entities
  module Github
    module Push

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::Commit, Entities::Github::CommitComment]
      }

      class Procurer < Entities::Procurer
        include Entities::Github::Accessors

        def find(payload)
          if push_id(payload)
            find_by_push_id(push_id(payload))
          end
        end

        def build(payload)
          if type(payload) == 'Push'
            fill_props(build_from_push(payload), payload)
          else
            build_fail
          end
        end
        
        def find_by_push_id(push_id)
          @p.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{push_id}'")
            .first
        end

        def build_from_push(payload)
          @p.new(extracted(payload))
        end
      end

    end
  end
end
