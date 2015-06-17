require 'events/all_events'
require 'entities/all_entities'

module Entities

  def self.entity_instance(event)
    entity_class(event).new
  end

  def self.entity_class(event)
    FeedClassDeterminator.new(event).feed_class::TypeClassDeterminator.new(event).type_class
  end

  class FeedModuleDeterminator
    def initialize(event)
      fail DispatchError.new('Dispatcher requires an Event to work.') if !event.kind_of?(Events::Protocol)
      @event = event
    end

    def feed_module
      if Entities.constants.include?(feed_name)
        Entities.const_get(feed_name)
      else
        fail DeterminationError.new("Non-existent Entity feed.", feed_name)
      end
    end

    def feed_name
      @event.feed_name.to_sym
    end
  end

  class BaseTypeClassDeterminator
    def initialize(event)
      @event = event
    end

    def type_class(args = {})
      if !args.empty?
        find_type_class(args.fetch(:namespace), args.fetch(:type_name))
      elsif block_given?
        yield
      else
        fail DeterminationError.new("Non-existent Entity type.", source_data)
      end
    end

    def find_type_class(namespace, type_name)
      if namespace.constants.include?(type_name)
        namespace.const_get(type_name)
      end
    end

    def source_data
      @event.source_data
    end
  end
  
  module Disqus
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Disqus::Post }
      end
    end
  end

  module Facebook
    class TypeClassDeterminator < BaseTypeClassDeterminator

      def type_class
        super({ namespace: Facebook, type_name: type_name })
      end

      # Pluck type from Facebook's source_data
      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end
  
  module Foursquare
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Foursquare::Checkin }
      end
    end
  end

  module Github
    class TypeClassDeterminator < BaseTypeClassDeterminator

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

  module Instagram
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Instagram::Media }
      end
    end
  end

  module Meetup
    class TypeClassDeterminator < BaseTypeClassDeterminator

      Mappings = {
        :EventEvent => :Event,
        :RsvpEvent => :Rsvp
      }

      def type_class
        super({ namespace: Meetup, type_name: remapped_type })
      end

      private
      def remapped_type
        Mappings[@event.type_name.to_sym]
      end
    end
  end
  
  module Rss
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Rss::Post }
      end
    end
  end

  module Stackexchange
    class TypeClassDeterminator < BaseTypeClassDeterminator

      Mappings = {
        :QuestionEvent => :Question,
        :AnswerEvent => :Answer,
        :CommentEvent => :Comment
      }

      def type_class
        super({ namespace: Stackexchange, type_name: remapped_type })
      end

      private
      def remapped_type
        Mappings[@event.type_name.to_sym]
      end
    end
  end
  module Tumblr
    class TypeClassDeterminator < BaseTypeClassDeterminator

      def type_class
        super({ namespace: Tumblr, type_name: type_name })
      end

      # Tumblr sends a type attribute in the response,
      # which we read and use to determine the type_name
      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end

  module Twitter
    class TypeClassDeterminator < BaseTypeClassDeterminator

      Mappings = {
        :TweetEvent => :Tweet,
        :FollowEvent => :Follow,
        :CustomFollowEvent => :Follow,
        :FakeFollowEvent => :Follow,
      }

      def initialize(event)
        super
        @mappings = Hash.new(@event.type_name).merge(Mappings)
      end

      def type_class
        super({ namespace: Twitter, type_name: remapped_type })
      end

      private
      def remapped_type
        @mappings[@event.type_name.to_sym]
      end
    end
  end

  module Youtube
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Youtube::Video }
      end
    end
  end
end
