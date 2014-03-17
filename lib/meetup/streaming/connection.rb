require 'http/parser'
require 'resolv'

module Meetup
  module Streaming

    class Connection
      def stream(request, response)
        client = TCPSocket.new(Resolv.getaddress(request.uri.host), request.uri.port)

        request.stream(client)

        while body = client.readpartial(1024) # rubocop:disable AssignmentInCondition, WhileUntilModifier
          response << body
        end
      end
    end

  end
end

