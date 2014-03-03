module Entities
  module Github

    class PullRequest < Protocol

      def find
        @event.pull_request.id && find_by_pull_request_id.first
      end

      def build
        built = Entity.new({
          title: @event.pull_request.title,
          body: @event.pull_request.body,
          url: @event.pull_request.html_url,
          origin_ts: @event.pull_request.created_at,
          origin_id: @event.pull_request.id.to_s,
          props: {
            repo_name: @event.repo.name,
            number: @event.pull_request.number,
            state: @event.pull_request.state,
            label_names: @event.pull_request.labels.names_csv,
          }
        })

        built.props[:references_to] = ""

        if @event.actor
          built.props[:origin_author_id] = @event.actor.id
          built.props[:origin_author_name] = @event.actor.login
          built.props[:origin_author_avatar_url] = @event.actor.avatar_url
        end

        built
      end

      def find_children
        downstream = [Entities::Github::IssueAction, Entities::Github::IssueComment]
        if @event.repo.name && @event.pull_request.number
          downstream.reduce([]) do |acc, rl|
            acc += rl.new(@event).find_by_repo_name_and_number.all
          end
        end
      end

      def update
        @instance.title = @event.title
        @instance.body = @event.body
        @instance.props[:state] = @event.state
        @instance.props[:label_names] = @event.labels.names_csv
        @instance.props[:references_to] = ""
        super
      end

      def update_from_children
        if most_recent_child = @instance.children.sort{|x,y| x.origin_ts <=> y.origin_ts}.last
          most_recent_child.props.symbolize_keys!
          most_recent_child.source_data.symbolize_keys!

          data = most_recent_child.last_modified_by.source_data
          event = Events::Dispatcher.dispatch(data, 'github')

          @instance.title = event.title if event.respond_to? :title
          @instance.body = event.body if event.respond_to? :body
          @instance.props[:state] = event.state
          @instance.props[:label_names] = event.labels.names_csv if event.labels
        end
      end

      # Finders
      def find_by_pull_request_id
        Entity
        .feed('github')
        .type('pull_request')
        .where(origin_id: @event.pull_request.id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('pull_request')
        .where("props -> 'repo_name' = '#{@event.repo.name}'")
        .where("props -> 'number' = '#{@event.pull_request.number}'")
      end

    end

  end
end
