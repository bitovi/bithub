module Entities
  module Github
    module IssueComment

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def find(payload)
          if (issue_id = issue_id(payload))
            find_by_issue_id(issue_id(payload))
          elsif repo_name(payload) && issue_number(payload)
            find_by_repo_name_and_issue_number(repo_name(payload), issue_number(payload))
          end
        end

        def build(payload)
          build_from_issue_comment
        end

        def find_by_issue_id(issue_id)
          @p.tagged_with(['github', 'issue_comment'])
            .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_by_repo_name_and_issue_number(repo_name, issue_number)
          @p.tagged_with(['github', 'issue_comment'])
            .where("props -> 'repo_name' = '#{repo_name}'")
            .where("props -> 'issue_number' = '#{issue_number}'")
        end

        def build_from_issue_comment
          "ISSUE COMMENT"
        end
      end

    end
  end
end
