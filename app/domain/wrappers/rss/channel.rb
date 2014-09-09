require 'wrappers/data_accessible'

module Wrappers
  module Rss

    class Channel
      include DataAccessible
      include CoreHelpers

      has :title, :link, :description
      attr_reader :items

      def initialize(item)
        @data = symbolize_keys(item)
      end

    end
  end
end
