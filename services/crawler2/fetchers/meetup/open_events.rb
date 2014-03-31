module Fetchers
  module Meetup

    class OpenEvents
      def initialize(client)
        @client = client
      end

      def fetch
        params = @config.fetch(:params) { Hash.new }
        @client.fetch(:open_events, params)
      end
    end

  end
end
