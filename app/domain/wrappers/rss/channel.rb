module Wrappers
  module Rss

    class Channel
      extend DataAccessible
      include CoreHelpers

      has :title, :link, :description
      attr_reader :items

      def initialize(item)
        @data = symbolize_keys(item)
        @items = @data[:item].map{|i| Wrappers::Rss::Item.new(i)}
      end

    end
  end
end
