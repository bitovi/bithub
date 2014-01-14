module Entities
  module Github

    class PullRequest
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }


      def procure
        if @payload.pull_request_id && (entity = find_by_pull_request_id(@payload.pull_request_id).first)
          entity
        else
          build
        end
      end

      def procure_parent
      end

      def procure_children
        if @payload.repo_name && @payload.issue_or_pull_req_number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl::Procurer.new(@p)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.issue_or_pull_req_number
            ).all
          end
        end
      end

      def procure_references
      end

      # Builder
      def build
        @persistor.new({
          title: "Pull request ##{@payload.number} #{@payload.action}",
          body: @payload.body,
          url: @payload.html_url,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            pull_request_id: @payload.pull_request_id,
            state: @payload.state,
            action: @payload.action, # IssuePullRequestAction?
          }
        })
      end

      # Finders
      def find_by_pull_request_id(pr_id)
        @persistor.tagged_with(['github', 'pull_request'])
        .where("props -> 'pull_request_id' = '#{pr_id}'")
      end

      def find_by_repo_name_and_number(repo_name, number)
        @persistor.where("props -> 'repo_name' = '#{repo_name}'")
        .where("props -> 'number' = '#{number}'")
        .tagged_with(['github', 'pull_request'])
      end

      def relationships
        Entities::Github::PullRequest::Relationships
      end
    end

  end
end
