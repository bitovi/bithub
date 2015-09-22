require 'github_api'
require_relative 'common'

module Guzzler::Fetchers

  module Github
    class OrgActivity
      include Protocol
      include Github::Common

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        handle_errors do
          client.activity.events.auto_pagination = false
          client.activity.events.org(org_name)
        end
      end

      def initial_fetch
        handle_errors do
          client.activity.events.auto_pagination = true
          client.activity.events.org(org_name)
        end
      end

      private

      def org_name
        @job.config.fetch('name')
      end
    end
  end
end
