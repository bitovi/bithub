require_relative 'common'

module Guzzler::Fetchers

  module Twitter
    class Followers
      include Protocol
      include Twitter::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          client.follower_ids(user_handle).map do |uid| 
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
        @user_id ||= client.user(user_handle).id
      end
    end
  end
end
