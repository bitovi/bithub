module Wrappers
  module Rss

    class Item
      extend DataAccessible
      include CoreHelpers

      has :title, :link, :description
      maybe_has :category, :image

      def initialize(item)
        @data = symbolize_keys(item)
      end

      def pub_date
        Time.parse(@data.fetch(:pubDate))
      end

    end
  end
end
