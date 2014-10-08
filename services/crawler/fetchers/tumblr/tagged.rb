require_relative 'base'

module Fetchers
  module Tumblr

    class Tagged < Base
      # http://www.tumblr.com/docs/en/api/v2#tagged-method

      def initialize(tag, opts={})
        super opts
        @tag = tag
      end

      def fetch
        @result = @client.tagged @tag
      end

      def self.fetch(tag, opts={})
        self.new(tag, opts).fetch
      end

    end

  end
end
