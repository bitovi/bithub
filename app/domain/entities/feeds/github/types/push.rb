module Entities
  module Github
    module Push

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::CommitComment, Entities::Github::Commit],
        references: [Entities::Github::Issue, Entities::Github::PullRequest],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          if payload.push_id
            find_by_push_id(payload.push_id).all
          end
        end

        def find_parent
        end
        
        def find_children
          if payload.commit_shas
            p = Entities::Github::CommitComment::Procurer.new(@p)
            p.find_by_multiple_commit_shas(payload.commit_shas).all
          end
        end

        def find_references
          if payload.repo_name && payload.referenced_issue_number
            relationships[:references].reduce([]) do |acc, rl|
              acc += rl::Procurer.new(@p)
                .find_by_repo_name_and_number(
                  payload.referenced_repo_name,
                  payload.referenced_number
                ).all
            end
          end
        end

        def find_by_push_id(push_id)
          @p.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{push_id}'")
        end
        
        def find_by_commit_sha(commit_sha)
          @p.tagged_with(['github','push'])
            .where("props -> 'commit_shas' LIKE '%#{commit_sha}%'")
        end
      end

    end
  end
end
