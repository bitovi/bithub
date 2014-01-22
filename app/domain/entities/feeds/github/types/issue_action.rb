module Entities
  module Github

    class IssueAction < Protocol

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.issue_id && (entity = find_by_issue_id(@payload.issue_id).first)
          @instance ||= entity
        else
          @instance ||= build
        end
        self
      end

      def procure_parent
        if @payload.repo_name && @payload.number
          relationships[:upstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.first
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
      def find_by_issue_id
        Entity.tagged_with(['github', 'issue_pull_request_action'])
        .where("props -> 'issue_id' = '#{@payload.issue_id}'")
      end

      def find_by_pull_req_id
        Entity.tagged_with(['github', 'issue_pull_request_action'])
        .where("props -> 'pull_request_id' = '#{@payload.pull_req_id}'")
      end

      def find_by_repo_name_and_number
        Entity.where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")
        .tagged_with(['github', 'issue_pull_request_action'])
      end

      def relationships
        Entities::Github::IssueAction::Relationships
      end
    end

    PullRequestAction = IssueAction
  end
end
