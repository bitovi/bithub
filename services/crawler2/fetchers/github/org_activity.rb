require 'github_api'

module Fetchers
  module Github

    class OrgActivity
      def initialize(token, org)
        @org = org
        @client = ::Github.new oauth_token: token
      end

      def fetch
        @client.activity.events.public org: @org
      end

      def default_interval
        10
      end
    end

  end
end
