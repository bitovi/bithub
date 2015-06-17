require 'andand'
require 'core_ext'
require 'events/all_events'

module Events
  def self.event_instance(packet)
    event_class(packet).new
  end

  def self.event_class(packet)
    FeedModuleDeterminator.new(packet).feed_module::TypeClassDeterminator.new(packet).type_class
  end

  class FeedModuleDeterminator
    include CoreHelpers

    def initialize(data, hint=nil)
      @data = symbolize_keys(data)
      @hint = hint
    end

    def feed_module
      if Events.constants.include?(feed_name)
        @feed_class = Events.const_get(feed_name)
      else
        fail DeterminationError.new("Non-existent Event feed", feed_name)
      end
    end

    def feed_name
      raw_feed_name = @hint || @data.andand[:meta].andand[:feed_name]
      fail DeterminationError.new('ClassDeterminator requires a feed_name to work') unless raw_feed_name
      raw_feed_name.andand.camel_case.andand.to_sym
    end
      
    def source_data
      @data.fetch(:source_data)
    end
  end

  class BaseTypeClassDeterminator
    include CoreHelpers

    def initialize(data)
      @data = symbolize_keys(data)
    end

    def type_class
      if @type_class = yield
        @type_class
      else
        fail DeterminationError.new("Non-existent Event type", source_data)
      end
    end
    
    private
    def source_data
      @data.fetch(:source_data)
    end
  end
  
  module Disqus
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Disqus::PostEvent }
      end
    end
  end
  
  module Facebook
    class TypeClassDeterminator < BaseTypeClassDeterminator

      def type_class
        super do 
          if Events::Facebook.constants.include? type_name
            Events::Facebook.const_get type_name
          end
        end
      end

      def type_name
        "#{source_data[:type]}_event".camel_case.to_sym
      end
    end
  end
  
  module Foursquare
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Foursquare::CheckinEvent }
      end
    end
  end

  module Github
    class TypeClassDeterminator < BaseTypeClassDeterminator
      Mappings = { :IssuesEvent => :IssueEvent }

      def type_class
        super do
          if Github.constants.include?(remapped_type_name)
            @type_class = Github.const_get(remapped_type_name)
          end
        end
      end

      def remapped_type_name
        @mappings ||= Hash.new(type_name).merge!(Mappings)
        @mappings[type_name]
      end

      def type_name
        if github_event?
          source_data[:type].camel_case.to_sym
        elsif github_issue?
          :CustomIssueEvent
          # elsif github_pull_request?
          #   :CustomPullRequestEvent
        end
      end

      private
      def github_event?
        not(source_data[:type].nil?)
      end

      def github_issue?
        not(source_data[:labels].nil?)\
          && not(source_data[:state].nil?)\
          && not(source_data[:comments].nil?)
      end

      # def github_pull_request?
      #   not(source_data[:labels].nil?)\
      #     && not(source_data[:state].nil?)\
      #     && not(source_data[:comments].nil?)
      # end
    end
  end
  
  module Instagram
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Instagram::MediaEvent }
      end
    end
  end
  
  module Meetup
    class TypeClassDeterminator < BaseTypeClassDeterminator

      def type_class
        super do
          if source_data[:rsvp_id]
            Events::Meetup::RsvpEvent
          elsif source_data[:event_url]
            Events::Meetup::EventEvent
          end
        end
      end
    end
  end

  module Rss
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Rss::PostEvent }
      end
    end
  end

  module Stackexchange
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Stackexchange::QuestionEvent }
      end
    end
  end

  module Tumblr
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Tumblr::Post }
      end
    end
  end

  module Twitter
    class TypeClassDeterminator < BaseTypeClassDeterminator

      def type_class
        super do
          if Twitter.constants.include?(type_name)
            @type_class = Twitter.const_get(type_name)
          end
        end
      end

      def type_name
        if is_follow_event?
          :FollowEvent
        elsif is_fake_follow_event?
          :FakeFollowEvent
        elsif is_status_event?
          :TweetEvent
        elsif source_data[:custom_follow]
          :CustomFollowEvent
        end
      end

      def is_follow_event?
        (source_data[:event].andand == 'follow') && not(source_data[:source].nil?) && not(source_data[:target].nil?)
      end

      def is_fake_follow_event?
        (source_data[:event].andand == 'fake_follow') && not(source_data[:source].nil?) && not(source_data[:target].nil?)
      end

      def is_status_event?
        not(source_data[:text].nil?) && not(source_data[:user].andand[:screen_name].nil?)
      end

    end
  end

  module Youtube
    class TypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { Events::Youtube::VideoEvent }
      end
    end
  end
end
