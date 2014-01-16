require 'lib/sanitizer'
require 'events/feeds/forum/types/post'

module Events
  module Forum
    class Post; end

    def self.type(type_name)
      Events::Forum::Post
    end

    class Processor
      def initialize(response)
        @response = response
        @config = yield if block_given?
      end

      def parse
        @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
      end

      def extract
        parse['rss']['channel']['item']
      end

      def determine_event_type(original_hash)
        "Post"
      end
      
      def tags
        #tags: [@config.andand[:term]],
      end
    end

  end
end
