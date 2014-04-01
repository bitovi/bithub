module FeedConfigs
  module Builders
    class Base

      def initialize(oauth_data)
        @oauth_data = HashWithIndifferentAccess.new(oauth_data)
        yield if block_given?
      end

    end
  end
end
