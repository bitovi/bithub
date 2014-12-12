module Identities
  module Builders
    class Base
      class InvalidArguments < Exception; end

      attr_accessor :data

      def initialize(args)
        args = HashWithIndifferentAccess.new args
        raise InvalidArguments unless args.include? :oauth

        @data = args
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

      def present
        {}
      end

      def credentials
        {
          access_token: access_token
        }
      end

      def present_with_credentials
        present.merge credentials
      end

    end
  end
end
