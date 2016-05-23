require 'bits/protocol'
require_relative 'shared'

module Bits
  module Github

    class IssueAction < Protocol
      include Shared

      def find
        nil
      end

      def find_parent
        return unless @event.repo.name && @event.number

        upstream = [Bits::Github::Issue, Bits::Github::PullRequest]
        upstream.reduce([]) do |acc, rl|
          acc << rl.new(@event).find_by_repo_name_and_number.first
        end.compact.first
      end

      def data
        with_commons({
          title: "#{@event.nice_name} ##{@event.number} #{@event.action}",
          props: {
            number: @event.number,
            state: @event.state,
            action: @event.action,
            label_names: @event.labels.andand.names_csv,
          }
        })
      end

      def update_parent
        @instance.parent.title = @event.title
        @instance.parent.body = @event.body
        @instance.parent.props['state'] = @event.state
        @instance.parent.props['label_names'] = @event.labels.andand.names_csv
      end

      # Finders
      def find_by_origin_id
        Bit.feed('github')
          .type(my_type_tag)
          .where(origin_id: @event.id.to_s)
      end

      def find_by_repo_name_and_number
        Bit
          .feed('github')
          .type(my_type_tag)
          .repo_name(@event.repo.name)
          .number(@event.number)
      end

      def my_type_tag
        'issue_action' if self.class.name =~ /Issue/
      end
    end
  end
end
