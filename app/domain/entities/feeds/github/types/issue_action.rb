module Entities
  module Github

    class IssueAction < Protocol

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def find
        @payload.issue_id && find_by_origin_id.first
      end

      # Builder
      def build
        Entity.new({
          title: "Issue ##{@payload.number} #{@payload.action}",
          origin_ts: @payload.origin_ts,
          origin_id: @payload.origin_id.to_s,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            repo_name: @payload.repo_name,
            number: @payload.number,
            label_names: @payload.label_names,
            state: @payload.state,
            action: @payload.action,
          }
        })
      end

      def find_parent
        if @payload.repo_name && @payload.number
          matches = relationships[:upstream].reduce([]) do |acc, rl|
            acc << rl.new(@payload).find_by_repo_name_and_number.first
          end
          parent = matches.compact.first
          # parent.update_from_child(@payload.issue)
          parent
        end
      end

      # Finders
      def find_by_origin_id
        Entity
        .feed('github')
        .type('issue_action')
        .where(origin_id: (@payload.issue_id || @payload.pull_request_id).to_s)
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
