require_relative 'types/post'

module Events
  module Blog
    class Post < Protocol; end

    def self.type(sd)
      Events::Blog::Post
    end

    class Processor
      def initialize(response)
        @response = response
      end

      def parse
        @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
      end

      def extract
        @extracted ||= parse['rss']['channel']['item']
      end

      def decorate
      end
    end
  end
end
