require_relative 'common'

module Fetchers
  module Github

    class RepoIssues
      include Protocol
      include Github::UnknownGithubErrorHandler

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoIssues"

        handle_errors do
          resp = @client.issues.list(user: @user, repo: @repo)
          handle_unknown_response(resp) do
            @client.issues.list(user: @user, repo: @repo)
          end
        end
      end

      def reset_settings_from_redirect(resp)
        @user, @repo = HTTParty.get(resp['url'])[0]['url'].match(/repos\/(.*)\/issues/)[1].split('/')
      rescue => e
        Celluloid.logger.error "[FETCHER] Error in Github/RepoIssues while trying to reset @user and @repo"
        [ ]
      end
    end
  end
end
