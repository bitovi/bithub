require_relative 'types/post'

module Events
  module Disqus
    class Post < Protocol; end

    def self.type(source_data)
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
