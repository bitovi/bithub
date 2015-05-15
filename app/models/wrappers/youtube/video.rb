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
        # 'id.videoId' for results from search.list
        # 'snippet.resourceId.videoId' for results from playlist_items.list

        @data[:id].class == Hash ? @data[:id][:videoId] : snippet[:resourceId][:videoId]
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

      def snippet
        @data.fetch :snippet
      end

    end
  end
end
