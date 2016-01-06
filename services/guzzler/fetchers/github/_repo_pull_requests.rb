module Guzzler::Fetchers

  module Github
    class RepoPullRequests
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoPullRequests"

        handle_errors do
          @client.pull_requests.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
