module Fetchers
  module Twitter

    class Followers
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        ids = @client.follower_ids.map {|uid| uid}
        Celluloid.logger.debug "----------> #{ids}"
        []
      end
    end
  end
end
