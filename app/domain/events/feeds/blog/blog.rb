require 'events/feeds/blog/types/post'

module Events
  module Blog
    class Post; end

    def self.type(type_name)
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
        parse['rss']['channel']['item']
      end
    end

  end
end
