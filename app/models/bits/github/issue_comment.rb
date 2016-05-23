require 'bits/protocol'
require_relative 'shared'

module Bits
  module Github

    class IssueComment < Protocol
      include Shared

      def find
        @event.comment.id && find_by_comment_id.first
      end

      def find_parent
        return unless @event.repo.name && @event.ipr.number

        upstream = [Bits::Github::Issue, Bits::Github::PullRequest]
        upstream.reduce([]) do |acc, rl|
          acc << rl.new(@event).find_by_repo_name_and_number.first
        end.compact.first
      end

      def data
        with_commons({
          title: "Comment on issue ##{@event.ipr.number}",
          body: @event.comment.body,
          url: @event.comment.html_url,
          origin_id: @event.comment.id.to_s,
          props: {
            number: @event.ipr.number
          }
        })
      end

      def update
        @instance.body = @event.comment.body
        super
      end

      def update_parent
        @instance.parent.title = @event.ipr.title
        @instance.parent.body = @event.ipr.body
        @instance.parent.props['state'] = @event.ipr.state
        @instance.parent.props['labels_names'] = @event.ipr.labels.andand.names_csv
      end

      # Finders

      def find_by_comment_id
        Bit
          .feed('github')
          .type('issue_comment')
          .where(origin_id: @event.comment.id.to_s)
      end

      def find_by_repo_name_and_number
        Bit
          .feed('github')
          .type('issue_comment')
          .repo_name(@event.repo.name)
          .number(@event.ipr.number)
      end
    end
  end
end
