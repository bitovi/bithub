module Guzzler::Fetchers

  module Youtube
    class Playlist < Base

      def fetch
        log_fetch

        super do
          client.execute\
            api_method: youtube_api.playlist_items.list,
            parameters: {part: 'id,snippet', playlistId: target_id, maxResults: 50}
        end
      end
    end
  end
end
