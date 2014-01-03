module Entities
  module Github
    module Issue

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [Entities::Github::Issue]
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
          entity = @p.new(extracted(payload))
          entity.props = meta(payload)
          entity
        end

        def find_upstream(payload)
          find_issue_by_issue_id
        end

        def find_downstream(payload)
        end

        def find_referenced(payload)
        end

        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue'])
            .where("props -> 'issue_id' = '#{issue_id}'")
            .first
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
            .first
        end
        
        def relationships
          Entities::Github::Issue::Relationships
        end

      end
    end
  end
end
