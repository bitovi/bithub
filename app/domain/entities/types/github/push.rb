module Entities
  module Github
    class Push

      def find_pushes_by_commit_sha(commit_sha)
        query = {
          tags: %w(github push_event)
          props: { commit_shas: "LIKE #{commit_sha}" }
        }
      end

      def find_pushes_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
        query = {
          tags: %w(github push_event)
          props: {
            repo_name: repo_name
            referenced_issue_number: issue_nmb
          }
        }
      end

    end
  end
end
