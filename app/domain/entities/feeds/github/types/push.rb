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

        def procure
          if @payload.push_id && (entity = find_by_push_id.first)
            entity
          else
            build
          end
        end

        def procure_parent
        end
        
        def procure_children
          if @payload.commits
            commit_comments = Entities::Github::CommitComment::Procurer
              .new(@persistor, @payload)
              .find_by_multiple_commit_shas.all

            commits = Entities::Github::Commit::Procurer
              .new(@persistor, @payload)
              .procure

            entities = [] + commit_comments + commits
          end
        end

        def procure_references
          if @payload.repo_name && @payload.referenced_issue_number
            relationships[:references].reduce([]) do |acc, rl|
              acc += rl::Procurer.new(@p)
                .find_by_repo_name_and_number(
                  @payload.referenced_repo_name,
                  @payload.referenced_number
                ).all
            end
          end
        end

        def find_by_push_id
          @persistor.tagged_with(['github', 'push'])
            .where("props -> 'push_id' = '#{@payload.push_id}'")
        end
        
        def find_by_commit_id
          @persistor.tagged_with(['github', 'push'])
            .where("props -> 'commit_shas' LIKE '%#{@payload.commit_id}%'")
        end
      end

    end
  end
end
