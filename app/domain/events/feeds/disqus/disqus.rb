require 'events/feeds/disqus/types/post'

module Events
  module Disqus

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
        @parsed ||= Yajl::Parser.parse(@response)
      end

      def extract
        @extracted ||= parse['response']
      end

      def determine_event_type(original_hash)
        "Post"
      end
    end

  end
end
