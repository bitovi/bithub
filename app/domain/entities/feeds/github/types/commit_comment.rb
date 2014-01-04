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
          if payload.comment_id
            find_by_comment_id(payload.comment_id).all
          elsif payload.commit_sha
            find_by_commit_sha(payload.commit_sha).all
          end
        end
        
        private
        def find_by_comment_id(comment_id)
          @p.tagged_with(['github', 'commit_comment'])
            .where("props -> 'comment_id' = '#{comment_id}'")
        end

        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github', 'commit_comment'])
            .where("props -> 'commit_sha' = '#{commit_sha}'")
        end

        def find_by_commit_shas(commit_shas)
          @p.tagged_with(['github', 'commit_comment'])
            .where("position(props -> 'commit_sha' in '#{commit_shas}') > 0")
        end
        
        def relationships
          Entities::Github::CommitComment::Relationships
        end
      end

    end
  end
end
