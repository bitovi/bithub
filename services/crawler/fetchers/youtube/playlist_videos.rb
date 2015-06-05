module Fetchers
  module Youtube

    class PlaylistVideos < Base

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Youtube/PlaylistVideos"

        playlist_id = @opts.fetch :playlist_id

        super do
          @client.execute\
            api_method: youtube_api.playlist_items.list,
            parameters: {part: 'id,snippet', playlistId: playlist_id, maxResults: 50}
        end
      end

    end

  end
end
