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

        def find(payload)
          if payload.commit_id
            find_by_commit_id(payload.commit_id).all
          end
        end

        def find_parent(payload)
          if payload.commit_id
            p = Entities::Github::Push::Procurer.new(@p)
            p.find_by_commit_sha(payload.commit_id).first
          end
        end

        def find_children(payload)
        end

        def find_references(payload)
        end
        
        private
        
        def find_by_commit_id(commit_id)
          @p.tagged_with(['github', 'commit_comment'])
            .where("props -> 'commit_id' = '#{commit_id}'")
        end
        
        def find_by_multiple_commit_shas(commit_shas)
          @p.tagged_with(['github', 'commit_comment'])
            .where("position(props -> 'commit_id' in '#{commit_shas}') > 0")
        end

        def relationships
          Entities::Github::CommitComment::Relationships
        end
      end

    end
  end
end
