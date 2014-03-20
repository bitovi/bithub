module Fetchers
  module Meetup

    module Client

      def initialize(cfg)
        RMeetup::Client.api_key = cfg[:params][:key]
        @client = RMeetup::Client
        @config = cfg
      end

    end
  end
end
