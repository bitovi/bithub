module Presenters
  module FeedConfig
    class Stackexchange < Generic
      def config
        {
          token: brand_identity.data.andand[:access_token],
          terms: terms || []
        }
      end
    end
  end
end
