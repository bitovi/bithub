module Entities
  module Github
    class Issue

      def find_issues_by_issue_id(issue_id)
        query = {
          tags: %w(github issues_event),
          props: { issue_id: issue_id }
        }
      end

      def find_issues_by_repo_name_and_issue_number(repo_name, issue_number)
        query = {
          tags: %w(github issues_event),
          props: {
            repo_name: repo_name
            issue_number: issue_number
          }
        }
      end

    end
  end
end
