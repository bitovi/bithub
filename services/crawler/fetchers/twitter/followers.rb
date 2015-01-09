require 'twitter'

module Fetchers
  module Twitter
    class Followers
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        handle_errors do
          @client.follower_ids.map do |uid| 
            {
              source: {
                id: uid,
              },
              target: {
                id: user_id,
              },
              event: "fake_follow",
              created_at: Time.now.strftime("%a %b %d %H:%M:%S %z %Y")
            }
          end
        end
      end

      def user_id
        @user_id ||= @client.user.id
      end
    end
  end
end
