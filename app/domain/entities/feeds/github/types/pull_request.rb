module Entities
  module Github
    class PullRequest

      def find_pull_requests_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
        query = {
          tags: %w(github pull_request_event)
          props: {
            repo_name: repo_name,
            referenced_issue_number: referenced_issue_number
          }
        }
      end

    end
  end
end
