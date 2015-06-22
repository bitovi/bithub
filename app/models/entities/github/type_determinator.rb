module Entities
  module Github
    class TypeDeterminator < Entities::TypeDeterminator

      Mappings = {
        :IssueEvent => :Issue,
        :CustomIssueEvent => :Issue,
        :IssueCommentEvent => :IssueComment,
        :PullRequestEvent => :PullRequest,
        :PullRequestReviewEvent => :PullRequestReview,
        :WatchEvent => :Watch,
        :ForkEvent => :Fork,
        :PushEvent => :Push,
        :CreateEvent => :Create,
        :DeleteEvent => :Delete,
        :CustomWatchEvent => :Watch,
        :CustomIssueCommentEvent => :IssueComment,
        # :CustomPullRequestEvent => :PullRequest,
      }

      def initialize(event)
        super
        @mappings = Hash.new(@event.type_name).merge(Mappings)
      end

      def type_class
        super do
          if issue_action?
            Github::IssueAction
          elsif Github.constants.include?(remapped_type)
            Github.const_get(remapped_type)
          end
        end
      end

      private
      def remapped_type
        @mappings[@event.type_name.to_sym]
      end

      def issue_action?
        ((@event.class.name =~ /Issue/) || (@event.class.name =~ /PullRequest/)) &&
          not(@event.class.name =~ /IssueComment/) &&
          has_state? && has_action? && not(just_opened?)
      end

      def has_state?
        @event.respond_to?(:state)
      end

      def has_action?
        @event.respond_to?(:action)
      end

      def just_opened?
        @event.action == 'opened'
      end
    end
  end
end
