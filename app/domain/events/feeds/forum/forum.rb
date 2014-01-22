require 'lib/sanitizer'
require 'lib/configurable'
require_relative 'types/post'

module Events
  module Forum
    class Post < Protocol; end

    def self.type(type_name)
      Events::Forum::Post
    end

    class Processor
      include Configurable

      def initialize(response, &blk)
        initialize_config
        @response = response
      end

      def parse
        @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
      end

      def extract
        @extracted ||= parse['rss']['channel']['item']
      end

      def decorate
        { meta: { tags: [@config.andand[:term]] }}
      end
    end

  end
end
