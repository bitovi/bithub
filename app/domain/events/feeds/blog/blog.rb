require 'events/feeds/blog/types/post'

module Events
  module Blog

    def self.type(type_name)
      self.const_get(type_name)
    end

    class Processor
      attr_reader :parsed, :extracted
      
      def initialize(response)
        @response = response
        @config = yield if block_given?
      end

      def parse
        @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
      end

      def extract
        @extracted ||= parse['rss']['channel']['item']
      end
      
      def determine_event_type(original_hash)
        "Post"
      end
    end

  end
end
