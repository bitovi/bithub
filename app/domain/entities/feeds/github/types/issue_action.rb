module Entities
  module Github
    module IssueAction
      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: []
      }

      class Procurer < Entities::Procurer
        include Github::FindableByRepoNameAndIssueNumber
        include Github::FindableByIssueNumber

        def find(attrs)
          if (issue_id = attrs['issue_id'])
            find_issue_comment_by_issue_id(issue_id)
          elsif (repo_name = attrs['repo_name']) && (issue_number = attrs['issue_number'])
            find_issue_comment_by_repo_name_and_issue_number(repo_name, issue_number)
          else
            fail Entities::Errors::MissingAttrToFindWith, 'must have some attributes to find with'
          end
        end

        def build
          build_from_issue_comment
        end

      end

      module Finders
        def find_issue_by_issue_id(issue_id)
          tagged_with(['github', 'issues_event'])
          .where("props -> 'issue_id' = '#{issue_id}'")
        end

        def find_issue_by_repo_name_and_issue_number(repo_name, issue_number)
          .tagged_with(['github', 'issues_event'])
          .where("props -> 'repo_name' = '#{repo_name}'")
          .where("props -> 'issue_number' = '#{issue_number}'")
        end
      end

      module Builders
        def build_from_issue
        end

        def build_from_issue_comment
        end
      end

    end
  end
end
