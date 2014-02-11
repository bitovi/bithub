require 'entities/protocol'

module Entities

  class Dispatcher
    Mappings = {
      :Forums => :Forum,
    }

    def self.dispatch(event)
      new(event).dispatch
    end

    def initialize(event)
      if not(event.kind_of? Events::Protocol)
        fail Entities::MappingError.new('Dispatcher requires an Event instance to dispatch propertly', event)
      end
      @event = event
      @mappings = Hash.new(@event.feed_name)
      @mappings.merge(Mappings)
    end

    def remapped_feed
      @mappings[@event.feed_name]
    end

    def feed
      if (@feed = Entities.constants.include?(remapped_feed))
        @feed = Entities.const_get(remapped_feed)
      else
        fail MappingError.new("Couldn't find valid feed")
      end
    end

    def type
      if (d = @feed::Dispatcher.new(@event)) && (@type = d.type)
        @type
      else
        fail MappingError.new("Couldn't find valid type", @feed)
      end
    end

    def dispatch
      feed
      type.new(@event)
    end
  end

  module Bithub
    class Dispatcher
      def initialize(event)
        @event = event
      end

      def type
        if Bithub.constants.include?(@event.type_name)
          Bithub.const_get(@event.type_name)
        end
      end
    end
  end

  module Github
    class Dispatcher

      Mappings = {
        :CustomIssue => :Issue,
        :CustomWatch => :Watch,
      }

      def initialize(event)
        @event = event
        @mappings = Hash.new(@event.type_name)
        @mappings.merge(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name]
      end

      def type
        if issue_action? || pull_request_action?
          Github::IssueAction
        elsif Github.constants.include?(remapped_type)
          Github.const_get(remapped_type)
        end
      end

      def issue_action?
        (@event.nice_name =~ /Issue/) &&
          (not(@event.nice_name =~ /IssueComment/)) &&
          (not(just_opened?))
      end

      def pull_request_action?
        (@event.nice_name =~ /PullRequest/) &&
          (not(@event.nice_name =~ /IssueComment/)) &&
          (not(just_opened?))
      end

      def just_opened?
        @event.respond_to?(:state) &&
          @event.respond_to?(:action) &&
          @event.action == 'opened'
      end

    end
  end

  module Irc
    class Dispatcher
      def initialize(event)
        @event = event
      end

      def type
        Entities::Irc::Message
      end
    end
  end

  module Meetup
    class Dispatcher
      def initialize(event)
        @event = event
      end

      def type
        Meetup.const_get(@event.type_name) if Meetup.constants.include?(@event.type_name)
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
        @mappings = Hash.new(@event.type_name)
        @mappings.merge(Mappings)
      end

      def remapped_type
        @mappings[@event.type_name]
      end

      def type
        Twitter.const_get(remapped_type) if Twitter.constants.include?(remapped_type)
      end
    end
  end

end
