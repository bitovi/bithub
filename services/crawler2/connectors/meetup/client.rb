require 'meetup/streaming/client'

module Connectors
  module Meetup

    module Client
      def initialize(cfg)
        @client = ::Meetup::Streaming::Client.new
      end
    end

  end
end
