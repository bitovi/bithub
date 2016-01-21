require_relative 'common'
require 'github_api'

module Fetchers
  module Github

    class RepoActivity
      include Protocol
      include Github::UnknownGithubErrorHandler

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoActivity"

        handle_errors do
          @client.activity.events.auto_pagination = false
          resp = @client.activity.events.repos(user: @user, repo: @repo)

          handle_unknown_response(resp) do
            @client.activity.events.repos(user: @user, repo: @repo)
          end
        end
      end

      def reset_settings_from_redirect(resp)
        @user, @repo = HTTParty.get(resp['url'])[0]['repo']['name'].split('/')
      rescue => e
        Celluloid.logger.error "[FETCHER] Error in Github/RepoActivity while trying to reset @user and @repo"
        [ ]
      end

      def initial_fetch
        handle_errors do
          @client.activity.events.auto_pagination = true
          @client.activity.events.repos(user: @user, repo: @repo)
        end
      end
    end
  end
end
