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
        built = Entity.new({
          title: "Pull Request ##{@payload.number} #{@payload.action} opened : #{@payload.title}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.pull_request_id.to_s,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            label_names: @payload.label_names,
            state: @payload.state,
          }
        })

        if @payload.actor
          built[:origin_author_id] = @payload.actor_id
          built[:origin_author_name] = @payload.actor_login
          built[:origin_author_avatar_url] = @payload.actor_avatar_url
        end

        built
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body
        @instance.props[:label_names] = @payload.label_names
        @instance.props[:state] = @payload.state
        super
      end
      
      def update_from_children
      end

      def find_children
        if @payload.repo_name && @payload.number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.all
          end
        end
      end

      # Finders
      def find_by_pull_request_id
        Entity
        .feed('github')
        .type('pull_request')
        .where(origin_id: @payload.pull_request_id.to_s)
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
