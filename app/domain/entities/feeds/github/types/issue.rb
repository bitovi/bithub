module Entities
  module Github

    class Issue < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: []
      }

      def find
        @payload.issue_id && find_by_origin_id.first
      end

      def build
        built = Entity.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.issue_id.to_s,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            label_names: @payload.label_names,
            state: @payload.state,
          }
        })

        built.props[:references_to] = @payload.referenced_issue_numbers_csv unless @payload.referenced_issue_numbers_csv.blank?

        if @payload.actor
          built.props[:origin_author_id] = @payload.actor_id
          built.props[:origin_author_name] = @payload.actor_login
          built.props[:origin_author_avatar_url] = @payload.actor_avatar_url
        end

        built
      end

      def find_children
        if @payload.repo_name && @payload.number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.all
          end
        end
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body
        @instance.props[:label_names] = @payload.label_names
        @instance.props[:state] = @payload.state
        @instance.props[:references_to] = @payload.referenced_issue_numbers_csv
        super
      end

      def update_from_children
        if most_recent_child = @instance.children.sort{|x,y| x.origin_ts <=> y.origin_ts}.last

          most_recent_child.props.symbolize_keys!
          most_recent_child.source_data.symbolize_keys!

          data = most_recent_child.last_modified_by.source_data
          event = Events::Dispatcher.dispatch(data, 'github')

          @instance.title = (t = event.issue.andand[:title]) ? t : @instance.title
          @instance.body = (b = event.issue.andand[:body]) ? b: @instance.body
          @instance.props[:state] = event.state
          @instance.props[:label_names] = event.label_names
        end
      end

      # Finders
      def find_by_origin_id
        Entity
        .feed('github')
        .type('issue')
        .where(origin_id: @payload.issue_id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('issue')
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")
      end

      def relationships
        Entities::Github::Issue::Relationships
      end

      private

      def taggify_labels
        if @instance.props[:label_names]
          input = @instance.props[:label_names]
          Tagger.new(Tag.labels).find_tags(input)
        else
          []
        end
      end

    end
  end
end
