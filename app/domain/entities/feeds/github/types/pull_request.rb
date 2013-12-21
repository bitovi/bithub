module Entities
  module Github
    class PullRequest
      class Procurer

      module FindableByRepoNameAndRefIssueNmb
        def find_pull_requests_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
          tagged_with(['github', 'pull_request_event'])
          .name_and_number(repo_name, referenced_issue_number)
        end
      end

    end
  end
end
