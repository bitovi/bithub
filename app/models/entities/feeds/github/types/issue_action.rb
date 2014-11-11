module Entities
  module Github
    class IssueAction < Protocol
      def find
        nil
      end

      def find_parent
        return unless @event.repo.name && @event.number

        upstream = [Entities::Github::Issue, Entities::Github::PullRequest]
        upstream.reduce([]) do |acc, rl|
          acc << rl.new(@event).find_by_repo_name_and_number.first
        end.compact.first
      end

      # Builder
      def build
        built = Entity.new(
          title: "#{@event.nice_name} ##{@event.number} #{@event.action}",
          origin_ts: @event.created_at,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
            number: @event.number,
            state: @event.state,
            action: @event.action
          }
        )

        built.props[:label_names] = @event.labels.andand.names_csv
        built
      end

      def update_parent
        @instance.parent.title = @event.title
        @instance.parent.body = @event.body
        @instance.parent.props['state'] = @event.state
        @instance.parent.props['label_names'] = @event.labels.andand.names_csv
      end

      # Finders
      def find_by_origin_id
        Entity.feed('github')
          .type(my_type_tag)
          .where(origin_id: @event.id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
          .feed('github')
          .type(my_type_tag)
          .where("props -> 'repo_name' = :repo_name", repo_name: @event.repo.name)
          .where("props -> 'number' = :number", number: @event.number)
      end

      def my_type_tag
        'issue_action' if self.class.name =~ /Issue/
      end
    end
  end
end
