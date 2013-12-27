require 'entities/feeds/github/types/push'
require 'entities/feeds/github/types/commit'

module Entities
  module Github
    module CommitComment

      Relationships = {
        upstream: [Entities::Github::Push, Entities::Github::Commit],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def find(payload)
          if comment_id(payload)
            find_by_comment_id(comment_id(payload))
          elsif commit_sha(payload)
            find_by_commit_sha(payload(commit_sha(payload)
          end
        end

        def build(payload)
          if type(payload) == 'CommitComment'
            build_from_commit_comment
          else
            fail Entities::Errors::BuildingException, "don't know how to build the entity from supplied payload"
          end
        end
        
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

        def build_from_commit_comment(payload)
          "COMMIT COMMENT"
        end
      end

    end
  end
end
