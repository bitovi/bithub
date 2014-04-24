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
      end
    end
  end
end
