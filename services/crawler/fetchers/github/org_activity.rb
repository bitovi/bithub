require 'github_api'

module Fetchers
  module Github

    class OrgActivity
      include Protocol

      def initialize(client, opts)
        @client = client
        @org = opts.fetch(:org_name)
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/OrgActivity"

        handle_errors do
          @client.activity.events.auto_pagination = false
          @client.activity.events.org(@org)
        end
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
