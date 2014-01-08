module Entities
  module Github
    module Commit

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      class Builder
        def initialize(payload)
          @p = payload
        end

        def build_attrs
        end
      end

      class Procurer
        include Entities::ProcurementAPI

        def procure
          if @payload.commits && (commits = find_by_multiple_commit_shas.all)
            commits
          else
            build_many_from_push
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
          end
        end

        def find_by_multiple_commit_shas
          @persistor.tagged_with(['github', 'commit'])
            .where("position(props -> 'commit_sha' in '#{@payload.commit_shas_csv}') > 0")
        end
      end

    end
  end
end
