module Identities
  module Builders
    class Base
      class InvalidArguments < Exception; end

      attr_accessor :data

      def initialize(args)
        args = HashWithIndifferentAccess.new args
        raise InvalidArguments unless args.include? :oauth

        @data = args
        self
      end

      def build
        @data
      end

      def oauth
        @data[:oauth]
      end

      def info
        oauth[:info]
      end

    end
  end
end
