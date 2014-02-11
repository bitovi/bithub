require 'events/protocol'

module Events

  class BasicTypeDispatcher
    def initialize(response)
      @response = response
    end
  end

  class Dispatcher
    include Loggable

    def self.dispatch(sd, hint = nil)
      self.new(sd).dispatch(hint)
    end

    def initialize(sd)
      @source_data = CoreHelpers.symbolize_keys(sd)
    end

    def feed(hint)
      feed_name = hint.andand.camel_case.andand.to_sym || meta_feed_name
      if (feed_name && Events.constants.include?(feed_name))
        @feed = Events.const_get(feed_name)
      else
        fail DispatchingError.new("Couldn't find valid feed", (feed_name.nil? ? "feed_name is nil" : feed_name))
      end
    end

    def type
      if (d = @feed::Dispatcher.new(@source_data)) && (@type = d.type)
        @type
      else
        fail MappingError.new("Couldn't find valid type", @feed)
      end
    end
    
    def dispatch(hint)
      feed(hint)
      type.new(@source_data)
    end

    private
    def meta_feed_name
      @source_data.andand[:meta].andand[:feed_name] || @source_data.andand[:meta].andand[:feed]
    end
  end

  module Bithub
    class Dispatcher
      def initialize(sd)
        @source_data = sd
      end

      def type
        if not(@source_data[:scheduled_at].nil?)
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

      Mapping = {
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
        @mappings.merge(Mappings)
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

      def initialize(sd)
        @source_data = sd
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

      def initialize(sd)
        @source_data = sd
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
        Event::Irc::Message
      end
    end
  end
end
