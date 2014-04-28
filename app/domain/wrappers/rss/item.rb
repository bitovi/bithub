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

      def published
        if @data[:published]
          Time.parse(@data[:pubDate]).utc
        end
      end

      def link
        if @data[:entry_id]
          @data[:entry_id]
        elsif @data[:link]
          @data[:link]
        elsif @data[:url]
          @data[:url]
        end
      end
    end
  end
end
