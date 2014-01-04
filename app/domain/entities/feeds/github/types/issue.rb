module Entities
  module Github
    module Issue

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      class Procurer
        include Procurement::API
        include Entities::Github::IssueAttributeFinder

        def find_references(payload)
          if payload.referenced_issue_number
            find_by_repo_name_and_issue_number(
              payload.referenced_repo_name
              payload.referenced_issue_number
            )
          end
        end
        
        private
        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue'])
            .where("props -> 'issue_id' = '#{issue_id}'")
            .all
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
            .all
        end

        def relationships
          Entities::Github::Issue::Relationships
        end
        
      end
    end
  end
end
