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
        :CustomIssue => :Issue,
        :CustomWatch => :Watch,
        :CustomIssueComment => :IssueComment,
      }

      def initialize(event)
        @event = event
        @mappings = Hash.new(@event.type_name_sym)
        @mappings.merge!(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name_sym]
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
        :CustomFollow => :Follow,
      }

      def initialize(event)
        @event = event
        @mappings = Hash.new(@event.type_name_sym)
        @mappings.merge!(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name_sym]
      end

      def type
        Twitter.const_get(remapped_type) if Twitter.constants.include?(remapped_type)
      end
    end
  end

  module Bithub
    class Dispatcher < BasicTypeDispatcher
      def type
        Bithub.const_get(@event.type_name_sym) if Bithub.constants.include?(@event.type_name_sym)
      end
    end
  end

  module Meetup
    class Dispatcher < BasicTypeDispatcher
      def type
        Meetup.const_get(@event.type_name_sym) if Meetup.constants.include?(@event.type_name_sym)
      end
    end
  end

  module Stackexchange
    class Dispatcher < BasicTypeDispatcher
      def type
        Stackexchange.const_get(@event.type_name_sym)
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
        Entities::Facebook::Status
      end
    end
  end

  module Foursquare
    class Dispatcher < BasicTypeDispatcher
      def type
        ### TODO,
        Entities::Foursquare::Checkin
      end
    end
  end

end
