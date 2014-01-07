module Entities
  module Github
    module CommitComment

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def procure
          if @payload.commit_id && (entity = find_by_commit_id.first)
            entity
          else
            build
          end
        end

        def procure_parent
          if @payload.commit_id
            Entities::Github::Push::Procurer
              .new(@persistor, @payload)
              .find_by_commit_id
              .first
          end
        end

        def procure_children
        end

        def procure_references
        end
        
        def find_by_commit_id
          @persistor.tagged_with(['github', 'commit_comment'])
            .where("props -> 'commit_id' = '#{@payload.commit_id}'")
        end
        
        def find_by_multiple_commit_shas
          @persistor.tagged_with(['github', 'commit_comment'])
            .where("position(props -> 'commit_id' in '#{@payload.commit_shas_csv}') > 0")
        end
      end

    end
  end
end
