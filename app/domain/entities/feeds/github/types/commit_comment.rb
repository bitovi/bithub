module Entities
  module Github
    module CommitComment

      Relationships = {
        upstream: [Entities::Github::Push, Entities::Github::Commit],
        downstream: []
      }

      class Procurer < Entities::Procurer
      end

      module FindableByCommitSHA
        def find_commit_comments_by_commit_sha(commit_sha)
          tagged_with(['github', 'commit_comment_event'])
          .where("props -> 'commit_sha' = '#{commit_sha}'")
        end

        def find_commit_comments_by_commit_shas(commit_shas)
          tagged_with(['github', 'commit_comment_event'])
          .where("position(props -> 'commit_sha' in '#{commit_shas}') > 0")
        end
      end

    end
  end
end
