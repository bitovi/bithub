module Fetchers
  module Youtube

    class PlaylistVideos < Base

      def fetch
        playlist_id = @opts.fetch :playlist_id

        super do
          @client.execute\
            api_method: youtube_api.playlistItems.list,
            parameters: {part: 'id,snippet', playlistlId: playlist_id, maxResults: 50}
        end
      end

    end

  end
end
