module Fetchers
  module Twitter

    class Followers
      include Protocol

      def initialize(client, user_id)
        @client = client
        @user_id = user_id
      end

      def fetch
        @client.follower_ids.map do |uid| 
          {
            source: {
              id: uid,
            },
            target: {
              id: @user_id,
            },
            event: "fake_follow",
            created: Time.now.strftime("%a %b %d %H:%M:%S %z %Y")
          }
        end
      end
    end
  end
end
