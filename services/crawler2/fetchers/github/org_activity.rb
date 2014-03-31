require 'github_api'

module Fetchers
  module Github

    class OrgActivity
      def initialize(client, opts)
        @client = client
        @interval = opts.fetch(:interval) { 10 }
        @org = opts.fetch(:org_name)
      end
      attr_reader :interval

      def fetch
        @client.activity.events.public org: @org
      end
    end

  end
end
