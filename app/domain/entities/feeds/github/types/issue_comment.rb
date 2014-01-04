module Entities
  module Github
    module IssueComment

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [Entities::Github::Issue],
      }

      class Procurer
        include Procurement::API
        include Entities::Github::IssueAttributeFinder

        private
        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue_comment'])
            .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue_comment'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
        end
        
        def relationships
          Entities::Github::IssueComment::Relationships
        end
      end

    end
  end
end
