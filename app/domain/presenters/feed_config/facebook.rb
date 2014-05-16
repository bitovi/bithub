module Presenters
  module FeedConfig
    class Facebook < Generic
      def config
        {
          token: brand_identity.andand.data[:access_token],
          pages: feed_config.config.andand['pages'] || []
        }
      end
    end
  end
end
