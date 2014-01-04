module Entities
  module Github
    module PullRequest

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      class Procurer < Entities::Procurer
        include Entities::Github::Accessors
        
        def find_self(payload)
          if issue_id(payload)
            find_by_issue_id(issue_id(payload))
          elsif repo_name(payload) && issue_number(payload)
            find_by_repo_name_and_issue_number(repo_name(payload), issue_number(payload))
          end
        end

        def build_self(payload)
          entity = @p.new(payload)
          entity.props = meta(payload)
          entity
        end
        
        def find_by_pull_request_id(pr_id)
          @p.tagged_with(['github', 'pull_request'])
            .where("props -> 'pull_request_id' = '#{pr_id}'")
            .first
        end

        def find_by_repo_name_and_issue_number(repo_name, pr_number)
          @p.tagged_with(['github', 'pull_request'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'pull_request_number' = '#{pr_number}'")
            .first
        end

        
        def relationships
          Entities::Github::PullRequest::Relationships
        end
      end

    end
  end
end
