module Entities
  module Github

    class IssuePullRequestAction
      include Entities::Constructable

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.issue_id && (entity = find_by_issue_id(@payload.issue_id).first)
          entity
        else
          build
        end
      end

      def procure_parent
        if @payload.repo_name && @payload.issue_or_pull_req_number
          relationships[:upstream].reduce([]) do |acc, rl|
            acc += rl::Procurer.new(@p)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.issue_or_pull_req_number
            ).first
          end
        end
      end

      def procure_children
      end

      def procure_references
      end

      # Builder
      def build
      end

      # Finders
      def find_by_issue_id(issue_id)
        @persistor.tagged_with(['github', 'issue_action'])
        .where("props -> 'issue_id' = '#{issue_id}'")
      end

      def find_by_repo_name_and_number(repo_name, number)
        @persistor.where("props -> 'repo_name' = '#{repo_name}'")
        .where("props -> 'number' = '#{number}'")
        .tagged_with(['github', 'issue_action'])
      end

      def relationships
        Entities::Github::IssueAction::Relationships
      end
    end

  end
end
