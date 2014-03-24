require_relative 'client'

module Fetchers
  module Meetup

    class OpenEvents
      include Client

      def fetch
        params = @config.fetch(:params) { Hash.new }
        @client.fetch(:open_events, params)
      end
    end

  end
end
