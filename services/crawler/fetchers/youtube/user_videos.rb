module Fetchers
  module Youtube

    class UserVideos < Base

      def fetch
        super do
          @client.execute\
            api_method: youtube_api.search.list,
            parameters: {part: 'id,snippet', forMine: true, order: 'date', maxResults: 50, type: 'video'}
        end
      end

    end

  end
end
