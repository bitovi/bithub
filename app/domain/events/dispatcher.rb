require 'events/protocol'

module Events

  class BasicTypeDispatcher
    def initialize(source_data)
    end
  end

  class Dispatcher
    include CoreHelpers
    include Loggable

    Mappings = {
      :Forums => :Forum,
    }

    def self.dispatch(data, hint = nil)
      self.new(data, hint).dispatch
    end

    def self.feed(data, hint = nil)
      self.new(data, hint).feed
    end

    def self.type(data, hint = nil)
      self.new(data, hint).type
    end

    def initialize(data, hint=nil)
      @_raw = symbolize_keys(data)

      if (@feed_name = (hint || maybe_meta_feed_name).andand.camel_case.andand.to_sym).nil?
        fail DispatchError.new('Dispatcher requires a feed name dispatch propertly')
      end

      @mappings = Hash.new(@feed_name)
      @mappings.merge!(Mappings)
    end

    def feed
      @feed ||= dispatch_to_feed
    end

    def type
      @type ||= dispatch_to_type
    end

    def dispatch
      type.new(source_data)
    end

    def source_data
      @source_data ||= extracted_source_data(@_raw)
    end

    private
    def maybe_meta_feed_name
      @_raw[:meta].andand[:feed_name] || @_raw['meta'].andand['feed_name']
    end

    def remapped_feed_name
      @mappings[@feed_name]
    end

    def dispatch_to_feed
      if Events.constants.include?(remapped_feed_name)
        Events.const_get(remapped_feed_name)
      else
        fail DispatchError.new("Failed to dispatch to a feed in Events", remapped_feed_name)
      end
    end

    def dispatch_to_type
      if (t = feed::Dispatcher.new(source_data).type)
        t
      else
        fail DispatchError.new("Failed to dispatch to a type in Events", source_data)
      end
    end

    def extracted_source_data(sd)
      sd[:source_data].nil? ? sd : sd[:source_data]
    end
  end

  module Bithub
    class Dispatcher
      def initialize(sd)
        @source_data = sd
      end

      def type
        unless @source_data[:scheduled_at].blank?
          Events::Bithub::Event
        else
          Events::Bithub::Post
        end
      end

    end
  end

  module Github
    class Dispatcher
      attr_accessor :source_data

      Mappings = {
        :Issues => :Issue,
      }

      def initialize(sd)
        @source_data = sd
      end

      def type
        if Github.constants.include?(remapped_type_name)
          Github.const_get(remapped_type_name)
        end
      end

      def remapped_type_name
        @mappings ||= Hash.new(type_name)
        @mappings.merge!(Mappings)
        @mappings[type_name]
      end

      private

      def type_name
        if github_event?
          @source_data[:type].camel_case.gsub(/Event/,'').camel_case.to_sym
        elsif github_issue?
          :CustomIssue
        elsif @source_data[:custom_watch]
          :CustomWatch
        end
      end

      def github_event?
        not(@source_data[:type].nil?)
      end

      def github_issue?
        not(@source_data[:labels].nil?) && not(@source_data[:state].nil?) && not(@source_data[:comments].nil?)
      end
    end
  end

  module Meetup
    class Dispatcher

      def initialize(source_data)
        @source_data = source_data
      end

      def type
        if @source_data[:rsvp_id]
          Events::Meetup::Rsvp
        elsif @source_data[:event_url]
          Events::Meetup::Event
        end
      end
    end
  end

  module Twitter
    class Dispatcher
      attr_reader :source_data

      def initialize(source_data)
        @source_data = source_data
      end

      def type
        if Twitter.constants.include?(type_name)
          Twitter.const_get(type_name)
        end
      end

      def type_name
        if is_follow_event?
          :Follow
        elsif is_status_event?
          :Tweet
        elsif source_data[:custom_follow]
          :CustomFollow
        end
      end

      def is_follow_event?
        (@source_data[:event].andand == 'follow') && not(@source_data[:source].nil?) && not(@source_data[:target].nil?)
      end

      def is_status_event?
        not(@source_data[:text].nil?) && not(@source_data[:user].andand[:screen_name].nil?)
      end

    end
  end

  module StackExchange
    class Dispatcher < BasicTypeDispatcher
      def type
        Events::StackExchange::Question
      end
    end
  end

  module Blog
    class Dispatcher < BasicTypeDispatcher
      def type
        Events::Blog::Post
      end
    end
  end

  module Disqus
    class Dispatcher < BasicTypeDispatcher
      def type
        Events::Disqus::Post
      end
    end
  end

  module Forum
    class Dispatcher < BasicTypeDispatcher
      def type
        Events::Forum::Post
      end
    end
  end

  module Irc
    class Dispatcher < BasicTypeDispatcher
      def type
        Events::Irc::Message
      end
    end
  end
end
