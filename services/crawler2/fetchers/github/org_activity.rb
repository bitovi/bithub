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
        @client.activity.events.public org: @org
      end
    end
  end
end
