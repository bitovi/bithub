module Entities
  module Github

    class PullRequest < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      def procure
        @instance = (@payload.pull_request_id && (e = find_by_pull_request_id.first)) ? e : build
        self
      end

      def procure_parent
      end

      def procure_children
        if @payload.repo_name && @payload.number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.number
            ).all
          end
        end
      end

      def procure_references
      end

      # Builder
      def build
        e = Entity.new({
          title: "Pull request ##{@payload.number} #{@payload.action}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            number: @payload.number,
            pull_request_id: @payload.pull_request_id,
            state: @payload.state,
            action: @payload.action, # IssuePullRequestAction?
          }
        })
        e.props.symbolize_keys!
        e
      end

      # Finders
      def find_by_pull_request_id
        Entity.tagged_with(['github', 'pull_request'])
        .where("props -> 'pull_request_id' = '#{@payload.pull_request_id}'")
      end

      def find_by_repo_name_and_number
        Entity.where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")
        .tagged_with(['github', 'pull_request'])
      end


      def relationships
        Entities::Github::PullRequest::Relationships
      end
    end

  end
end
