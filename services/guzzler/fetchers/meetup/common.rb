require 'rmeetup'

module Guzzler::Fetchers
  module Meetup
    module Common

      def event_ids_cache
        "cache:#{@job.tenant_name}:meetup_events"
      end

      def client
        @client ||= ::RMeetup::Client.new api_key: api_key
      end

      def api_key
        Guzzler.static_config.fetch(:meetup).fetch(:personal_key)
      end
    end
  end
end
