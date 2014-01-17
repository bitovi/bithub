require 'events/feeds/disqus/types/post'

module Events
  module Disqus
    class Post; end

    def self.type(type_name)
      Events::Disqus::Post
    end

    class Processor
      def initialize(response)
        @response = response
      end

      def parse
        @parsed ||= Yajl::Parser.parse(@response)
      end

      def extract
        @extracted = parse['response']
      end

      def decorate
      end
    end

  end
end
