module Fetchers
  module Youtube

    class UserVideos < Base

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Youtube/UserVideos"

        super do
          @client.execute\
            api_method: youtube_api.search.list,
            parameters: {part: 'id,snippet', forMine: true, order: 'date', maxResults: 50, type: 'video'}
        end
      end

    end

  end
end
