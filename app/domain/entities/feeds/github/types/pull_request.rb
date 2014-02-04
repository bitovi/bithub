module Entities
  module Github

    class PullRequest < Protocol
      include Entities::Github::Referencable
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      def find
        @payload.pull_request_id && find_by_pull_request_id.first
      end
      
      def build
        Entity.new({
          title: "Pull request ##{@payload.number} #{@payload.action}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.pull_request_id.to_s,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            state: @payload.state,
          }
        })
      end

      def find_children
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

      # Finders
      def find_by_pull_request_id
        Entity
        .feed('github')
        .type('pull_request')
        .where(origin_id: @payload.pull_request_id)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('pull_request')
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")
      end

      def relationships
        Entities::Github::PullRequest::Relationships
      end
    end

  end
end
