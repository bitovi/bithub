require 'sanitizer'
require_relative 'types/post'

module Events
  module Forum
    class Post < Protocol; end

    def self.type(type_name)
      Events::Forum::Post
    end

    class Processor
      class Configuration
        attr_accessor :term
      end

      def initialize(response, &blk)
        @config = Configuration.new
        blk.(@config) if blk

        @response = response
      end

      def parse
        @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
      end

      def extract
        @extracted ||= parse['rss']['channel']['item']
      end

      def decorate
        { meta: { term: [@config.term] }}
      end
    end

  end
end
