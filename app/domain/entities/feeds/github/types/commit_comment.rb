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
            find_by_commit_sha(commit_sha(payload))
          end
        end

        def build(payload)
          if type(payload) == 'CommitComment'
            fill_props(build_from_commit_comment(payload), payload)
          else
            build_fail
          end
        end
        
        def find_by_comment_id(comment_id)
          @p.tagged_with(['github', 'commit_comment'])
            .where("props -> 'comment_id' = '#{comment_id}'")
            .first
        end

        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github', 'commit_comment'])
            .where("props -> 'commit_sha' = '#{commit_sha}'")
            .first
        end

        def find_by_commit_shas(commit_shas)
          @p.tagged_with(['github', 'commit_comment'])
            .where("position(props -> 'commit_sha' in '#{commit_shas}') > 0")
            .first
        end

        def build_from_commit_comment(payload)
          @p.new(extracted(payload))
        end
      end

    end
  end
end
