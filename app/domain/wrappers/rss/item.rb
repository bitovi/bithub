require 'wrappers/data_accessible'

module Wrappers
  module Rss

    class Item
      include DataAccessible
      include CoreHelpers

      has :title
      maybe_has :category, :image, :summary, :categories, :description

      def initialize(item)
        @data = symbolize_keys(item)
      end

      def pub_date
        Time.parse(@data.fetch(:pubDate)).utc
      end

      def link
        if @data[:entry_id]
          @data[:entry_id]
        elsif @data[:link]
          @data[:link]
        end
      end
    end
  end
end
