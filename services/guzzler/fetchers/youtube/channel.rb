module Guzzler::Fetchers

  module Youtube
    class Channel < Base

      def fetch
        log_fetch

        super do
          client.execute\
            api_method: youtube_api.search.list,
            parameters: {part: 'id,snippet', channelId: target_id, order: 'date', maxResults: 50, type: 'video'}
        end
      end
    end
  end
end
