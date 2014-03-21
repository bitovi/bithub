require 'rmeetup'

module Fetchers
  module Meetup

    module Client

      def initialize(cfg)
        @config = cfg

        RMeetup::Client.api_key = @config[:params][:key]
        @client = RMeetup::Client
      end

    end
  end
end
