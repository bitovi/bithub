module Entities
  module Github
    class CommitComment

      def find_commit_comments_by_commit_sha(commit_sha)
        query = {
          tags: %w(github commit_comment_event),
          props: { commit_sha: commit_sha }
        }
        tagged_with().where("props -> 'commit_sha' = '#{commit_sha}'")
      end

      def find_commit_comments_by_multiple_commit_shas(commit_shas)
        query = {
          tags: %w(github commit_comment_event),
          props: { commit_sha: "IN #{commit_shas}" }
        }
      end

    end
  end
end
