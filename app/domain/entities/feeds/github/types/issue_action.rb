module Entities
  module Github

    class IssueAction < Protocol

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.issue_id && (e = find_by_issue_id.first)) ? e : build
        self
      end

      def find_parent
        if @payload.repo_name && @payload.number
          relationships[:upstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.first
          end
        end
      end

      # Builder
      def build
        Entity.new({
          title: "Issue ##{@payload.number} #{@payload.action}",
          origin_ts: @payload.origin_ts,
          origin_id: @payload.origin_id_to_s,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            label_names: @payload.label_names,
            state: @payload.state,
            action: @payload.action,
          }
        })
      end

      # Finders
      def find_by_issue_id
        Entity
        .feed('github')
        .type('issue_action')
        .where(origin_id: @payload.origin_id)
      end

      def find_by_pull_req_id
        Entity
        .feed('github')
        .type('issue_action')
        .where(origin_id: @payload.origin_id)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('issue_action')
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")
      end

      def relationships
        Entities::Github::IssueAction::Relationships
      end
    end

    PullRequestAction = IssueAction
  end
end
