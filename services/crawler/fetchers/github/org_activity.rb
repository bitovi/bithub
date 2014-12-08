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
        @client.activity.events.org @org
      rescue ::Github::Error::Forbidden => e
        Celluloid.logger.error "Github::OrgActivity fetcher error: #{e}"
        nil
      end
    end
  end
end
