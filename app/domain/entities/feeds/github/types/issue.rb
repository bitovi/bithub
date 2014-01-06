module Entities
  module Github
    module Issue

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          if payload.issue_id
            find_by_issue_id(payload.issue_id).first
          end
        end

        def find_parent(payload)
        end

        def find_children(payload)
          if payload.repo_name && payload.issue_or_pull_req_number
            relationships[:downstream].reduce([]) do |acc, rl|
              acc += rl::Procurer.new(@p)
                .find_by_repo_name_and_number(
                  payload.repo_name,
                  payload.issue_or_pull_req_number
                ).all
            end
          end
        end

        def find_references(payload)
        end
        
        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue'])
            .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_by_repo_name_and_number(repo_name, number)
          @p.where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'number' = '#{number}'")
            .tagged_with(['github', 'issue'])
        end

        def relationships
          Entities::Github::Issue::Relationships
        end
        
      end
    end
  end
end
