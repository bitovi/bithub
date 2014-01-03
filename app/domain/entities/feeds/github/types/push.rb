module Entities
  module Github
    module Push

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::Commit, Entities::Github::CommitComment]
      }

      class Procurer < Entities::Procurer
        include Entities::Github::Accessors

        def find_self(payload)
          if push_id(payload)
            find_by_push_id(push_id(payload))
          end
        end

        def build_self(payload)
          entity = @p.new(extracted(payload))
          entity.props = meta(payload)
          entity
        end
        
        def find_by_push_id(push_id)
          @p.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{push_id}'")
            .first
        end

        
        def relationships
          Entities::Github::Push::Relationships
        end
      end

    end
  end
end
