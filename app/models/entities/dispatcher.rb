require 'entities/protocol'

module Entities

  class BasicTypeDispatcher
    def initialize(event)
      @event = event
    end
  end

  class Dispatcher

    Mappings = {
      :Forums => :Forum,
    }

    def self.dispatch(event)
      new(event).dispatch
    end

    def self.feed(event)
      self.new(event).feed
    end

    def self.type(event)
      self.new(event).type
    end

    def initialize(event)
      if not(event.kind_of? Events::Protocol)
        fail DispatchError.new('Dispatcher requires an Event instance to dispatch propertly')
      end

      @event = event
      @mappings = Hash.new(@event.feed_name.camel_case.to_sym)
      @mappings.merge!(Mappings)
    end

    def feed
      @feed ||= dispatch_to_feed
    end

    def type
      @type ||= dispatch_to_type
    end

    def dispatch
      type.new(@event)
    end

    private
    def remapped_feed_name
      @mappings[@event.feed_name.camel_case.to_sym]
    end

    def dispatch_to_feed
      if Entities.constants.include?(remapped_feed_name)
        Entities.const_get(remapped_feed_name)
      else
        fail DispatchError.new("Failed to dispatch to a feed in Entities", remapped_feed_name)
      end
    end

    def dispatch_to_type
      if (type = feed()::Dispatcher.new(@event).type)
        type
      else
        fail DispatchError.new("Failed to dispatch to a type in Entities", @event)
      end
    end
  end

  module Github
    class Dispatcher

      Mappings = {
        :IssueEvent => :Issue,
        :CustomIssueEvent => :Issue,
        :IssueCommentEvent => :IssueComment,
        :PullRequestEvent => :PullRequest,
        # :CustomPullRequestEvent => :PullRequest,
        :PullRequestReviewEvent => :PullRequestReview,
        :WatchEvent => :Watch,
        :ForkEvent => :Fork,
        :PushEvent => :Push,
        :CreateEvent => :Create,
        :DeleteEvent => :Delete,
        :CustomWatchEvent => :Watch,
        :CustomIssueCommentEvent => :IssueComment,
      }

      def initialize(event)
        @event = event
        @mappings = Hash.new(@event.type_name)
        @mappings.merge!(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name.to_sym]
      end

      def type
        if issue_action?
          Github::IssueAction
        elsif Github.constants.include?(remapped_type)
          Github.const_get(remapped_type)
        end
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

  module Twitter
    class Dispatcher

      Mappings = {
        :TweetEvent => :Tweet,
        :FollowEvent => :Follow,
        :CustomFollowEvent => :Follow,
        :FakeFollowEvent => :Follow,
      }

      def initialize(event)
        @event = event
        @mappings = Hash.new(@event.type_name)
        @mappings.merge!(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name.to_sym]
      end

      def type
        if Twitter.constants.include?(remapped_type)
          Twitter.const_get(remapped_type)
        end
      end
    end
  end

  module Bithub
    class Dispatcher < BasicTypeDispatcher
      def type
        Bithub.const_get(@event.type_name) if Bithub.constants.include?(@event.type_name)
      end
    end
  end

  module Meetup
    class Dispatcher < BasicTypeDispatcher

      Mappings = {
        :EventEvent => :Event,
        :RsvpEvent => :Rsvp
      }

      def remapped_type
        Mappings[@event.type_name.to_sym]
      end

      def type
        if Meetup.constants.include? remapped_type
          Meetup.const_get remapped_type
        end
      end
    end
  end

  module Stackexchange
    class Dispatcher < BasicTypeDispatcher

      Mappings = {
        :QuestionEvent => :Question,
        :AnswerEvent => :Answer,
        :CommentEvent => :Comment
      }

      def remapped_type
        Mappings[@event.type_name.to_sym]
      end

      def type
        if Stackexchange.constants.include? remapped_type
          Stackexchange.const_get remapped_type
        end
      end
    end
  end

  module Forum
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Forum::Post
      end
    end
  end

  module Blog
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Blog::Post
      end
    end
  end

  module Rss
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Rss::Post
      end
    end
  end

  module Irc
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Irc::Message
      end
    end
  end

  module Disqus
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Disqus::Post
      end
    end
  end

  module Facebook
    class Dispatcher < BasicTypeDispatcher

      def type
        if Entities::Facebook.constants.include? type_name
          Entities::Facebook.const_get type_name
        else
          fail DispatchError.new("Failed to dispatch to a type in Entities::Facebook::#{type_name}")
        end
      end

      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end

  module Foursquare
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Foursquare::Checkin
      end
    end
  end

  module Instagram
    class Dispatcher < BasicTypeDispatcher
      def type
        Entities::Instagram::Media
      end
    end
  end

  module Tumblr
    class Dispatcher < BasicTypeDispatcher

      def type
        if Entities::Tumblr.constants.include?(type_name)
          Entities::Tumblr.const_get(type_name)
        else
          fail DispatchError.new("Failed to dispatch to a type in Entities::Tumblr::#{type_name}")
        end
      end

      # Tumblr sends a type attribute in the response,
      # which we read and use to determine the type_name
      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end

end
