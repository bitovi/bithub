module Entities
  module Github

    class IssueComment < Protocol
      include Entities::Github::Referencable

      def find
        @event.comment_id && find_by_comment_id.first
      end

      def find_parent
        upstream =[Entities::Github::Issue, Entities::Github::PullRequest]
        if @event.repo_name && @event.ipr.number
          upstream.reduce([]) do |acc, rl|
            acc << rl.new(@event).find_by_repo_name_and_number.first
          end.compact.first
        end
      end

      # Builder
      def build
        built = Entity.new({
          title: "Comment on issue ##{@event.ipr.number}",
          body: @event.comment.body,
          url: @event.comment.html_url,
          origin_ts: @event.comment.created_at,
          origin_id: @event.comment.id.to_s,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
            number: @event.ipr.number,
          }
        })

        built.props[:references_to] = ""
        built
      end

      def update
        @instance.body = @event.comment.body
        @instance.props[:references_to] = ""
        super
      end

      def update_parent
        @instance.parent.title = @event.ipr.title
        @instance.parent.body = @event.ipr.body
        @instance.parent.props[:state] = @event.ipr.state
        @instance.parent.props[:labels_names] = @event.ipr.lables.andand.names_csv
      end

      # Finders

      def find_by_comment_id
        Entity
        .feed('github')
        .type('issue_comment')
        .where(origin_id: @event.comment.id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('issue_comment')
        .where("props -> 'repo_name' = '#{@event.repo.name}'")
        .where("props -> 'number' = '#{@event.ipr.number}'")
      end

    end

  end
end
