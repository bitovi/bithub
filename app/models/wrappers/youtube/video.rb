require 'wrappers/data_accessible'

module Wrappers
  module Youtube

    class Video
      include DataAccessible
      include CoreHelpers

      def initialize(item)
        @data = symbolize_keys(item)
      end

      def id
        _id.fetch :videoId
      end

      def title
        snippet.fetch :title
      end

      def description
        snippet.fetch :description
      end

      def channel_title
        snippet.fetch :channelTitle
      end

      def channel_id
        snippet.fetch :channelId
      end

      def thumbnail
        snippet[:thumbnails][:high][:url]
      end

      def created_time
        Time.parse(snippet.fetch(:publishedAt)).utc
      end

      private

      def _id
        @data.fetch :id
      end

      def snippet
        @data.fetch :snippet
      end

    end
  end
end
