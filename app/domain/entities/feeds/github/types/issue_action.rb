module Entities
  module Github
    module IssueAction

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI
        include Entities::Github::IssueAttributeFinder

        private
        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue_action'])
            .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue_action'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
        end

        def relationships
          Entities::Github::IssueAction::Relationships
        end
      end

    end
  end
end
