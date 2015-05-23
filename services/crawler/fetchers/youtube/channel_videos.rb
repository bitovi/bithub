module Fetchers
  module Youtube

    class ChannelVideos < Base

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Youtube/ChannelVideos"

        channel_id = @opts.fetch :channel_id
        super do
          @client.execute\
            api_method: youtube_api.search.list,
            parameters: {part: 'id,snippet', channelId: channel_id, order: 'date', maxResults: 50, type: 'video'}
        end
      end

    end

  end
end
