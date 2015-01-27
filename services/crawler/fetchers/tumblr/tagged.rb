require_relative 'base'
require_relative '../protocol'

module Fetchers
  module Tumblr

    class Tagged < Base
      include Protocol
      # http://www.tumblr.com/docs/en/api/v2#tagged-method

      def initialize(tag, opts={})
        super opts
        @tag = tag
      end

      def fetch
        handle_errors do
          @result = @client.tagged @tag
        end
      end

      def self.fetch(tag, opts={})
        self.new(tag, opts).fetch
      end

    end

  end
end
