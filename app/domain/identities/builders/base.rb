module Identities
  module Builders
    class Base
      class InvalidArguments < Exception; end

      attr_accessor :data

      def initialize(args)
        raise InvalidArguments unless args.include? :oauth

        @data = HashWithIndifferentAccess.new({custom: {}}.merge args)
        self
      end

      def build
        @data
      end

      def oauth
        @data[:oauth]
      end

      def custom
        @data[:custom]
      end

    end
  end
end
