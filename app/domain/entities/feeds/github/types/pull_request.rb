module Entities
  module Github
    module PullRequest

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def procure
          if @payload.pull_request_id && (entity = find_by_pull_request_id(@payload.pull_request_id).first)
            entity
          else
            build
          end
        end
        
        def find_parent
        end

        def find_children
          if @payload.repo_name && @payload.issue_or_pull_req_number
            relationships[:downstream].reduce([]) do |acc, rl|
              acc += rl::Procurer.new(@p)
                .find_by_repo_name_and_number(
                  @payload.repo_name,
                  @payload.issue_or_pull_req_number
                ).all
            end
          end
        end

        def find_references
        end

        def find_by_pull_request_id(pr_id)
          @persistor.tagged_with(['github', 'pull_request'])
            .where("props -> 'pull_request_id' = '#{pr_id}'")
        end

        def find_by_repo_name_and_number(repo_name, number)
          @persistor.where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'number' = '#{number}'")
            .tagged_with(['github', 'pull_request'])
        end
        
        def relationships
          Entities::Github::PullRequest::Relationships
        end
      end

    end
  end
end
