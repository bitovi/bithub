module Guzzler::Fetchers

  module Youtube
    class User < Base

      def fetch
        log_fetch

        super do
          client.execute\
            api_method: youtube_api.search.list,
            parameters: {part: 'id,snippet', forMine: true, order: 'date', maxResults: 50, type: 'video'}
        end
      end

    end

  end
end
