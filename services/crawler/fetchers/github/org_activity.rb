require_relative 'common'
require 'github_api'

module Fetchers
  module Github

    class OrgActivity
      include Protocol
      include Github::UnknownGithubErrorHandler

      def initialize(client, opts)
        @client = client
        @org = opts.fetch(:org_name)
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/OrgActivity"

        handle_errors do
          @client.activity.events.auto_pagination = false
          resp = @client.activity.events.org(@org)

          handle_unknown_response(resp) do
            @client.activity.events.org(@org)
          end

        end
      end
      
      def reset_settings_from_redirect(resp)
        @org = HTTParty.get(resp['url'])[0]['org']['login']
      rescue => e
        Celluloid.logger.error "[FETCHER] Error in Github/OrgActivity while trying to reset @user and @repo"
        [ ]
      end

      def initial_fetch
        handle_errors do
          @client.activity.events.auto_pagination = true
          @client.activity.events.org(@org)
        end
      end
    end
  end
end
