module Entities
  module Github
    module Push

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::Commit, Entities::Github::CommitComment],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          if payload.push_id
            find_by_push_id(payload.push_id).all
          end
        end

        private
        def find_by_push_id(push_id)
          @p.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{push_id}'")
        end

        def relationships
          Entities::Github::Push::Relationships
        end
      end

    end
  end
end
