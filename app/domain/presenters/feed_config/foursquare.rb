module Presenters
  module FeedConfig
    class Foursquare < Generic
      def config
        { venues: (feed_config.config.andand['venues'] || []).map {|v| {id: v['id']}} }
      end
    end
  end
end
