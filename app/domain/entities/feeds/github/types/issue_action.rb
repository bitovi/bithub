module Entities
  module Github
    module IssueAction

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: []
      }

      class Procurer < Entities::Procurer
        include Entities::Github::Accessors

        def find(payload)
          if issue_id(payload)
            find_by_issue_id(issue_id(payload))
          elsif repo_name(payload) && issue_number(payload)
            find_by_repo_name_and_issue_number(repo_name(payload), issue_number(payload))
          end
        end

        def build(payload)
          if type(payload) == 'Issue'
            build_from_issue
          else
            fail Entities::Errors::BuildingException, "don't know how to build the entity from supplied payload"
          end
        end

        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue_action'])
            .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue_action'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
        end

        def build_from_issue
          "ISSUE_ACTION"
        end
      end

    end
  end
end
