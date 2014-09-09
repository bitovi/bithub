module Entities
  module Github

    class Issue < Protocol
      include Entities::Github::Referencable

      def find
        @event.issue.id && find_by_issue_id.first
      end

      def build
        built = Entity.new({
          title: @event.issue.title,
          body: @event.issue.body,
          url: @event.issue.html_url,
          origin_id: @event.issue.id.to_s,
          origin_ts: @event.origin_timestamp,
          props: {
            repo_name: @event.repo.name,
            number: @event.issue.number,
            label_names: @event.issue.labels.names_csv,
            state: @event.issue.state,
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
        if @event.repo.name && @event.number
          downstream.reduce([]) do |acc, rl|
            acc += rl.new(@event).find_by_repo_name_and_number.all
          end
        end
      end

      def update
        @instance.title = @event.title
        @instance.body = @event.body
        @instance.props[:label_names] = @event.labels.names_csv
        @instance.props[:state] = @event.state
        @instance.props[:references_to] = ""
        super
      end

      def update_from_children
        if (most_recent_child = @instance.children.sort{|x,y| x.origin_ts <=> y.origin_ts}.last)
          most_recent_child.props.symbolize_keys!
          most_recent_child.source_data.symbolize_keys!

          data = most_recent_child.last_modified_by.source_data
          event = Events::Dispatcher.dispatch(data, 'github')

          # IssueComment, has an embedded Issue or PullRequest that have labels etc
          if event.respond_to? :ipr
            @instance.title = event.ipr.title
            @instance.body = event.ipr.body
            @instance.props[:state] = event.ipr.state
            @instance.props[:label_names] = event.ipr.labels.names_csv

          # Issue, has own labels etc
          else
            @instance.title = event.title
            @instance.body = event.body
            @instance.props[:state] = event.state
            @instance.props[:label_names] = event.labels.names_csv
          end
        end
      end

      # Finders
      def find_by_issue_id
        Entity
        .feed('github')
        .type('issue')
        .where(origin_id: @event.issue.id.to_s)
      end

      def find_by_repo_name_and_number
        number = if @event.respond_to? :issue
                   @event.issue.number
                 elsif @event.respond_to? :pull_request
                   @event.pull_request.number
                 end

        Entity
        .feed('github')
        .type('issue')
        .where("props -> 'repo_name' = '#{@event.repo.name}'")
        .where("props -> 'number' = '#{number}'")
      end

      def taggify_labels
        if @instance.props[:label_names]
          input = @instance.props[:label_names]
          tags  = Tag.tagged_with('labels')

          Tagger::List.new(tags).taggify(input)
        else
          []
        end
      end

    end
  end
end
