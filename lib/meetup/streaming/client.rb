require 'http/request'

module Meetup
  module Streaming

    class Client
      attr_writer :connection

      def initialize(options = {})
        @connection = Streaming::Connection.new
      end

      def rsvps(options = {}, &block)
        request(:post, 'http://stream.meetup.com/2/rsvps', options, &block)
      end

      def open_events(options = {}, &block)
        request(:get, 'http://stream.meetup.com/2/open_events', options, &block)
      end

      def event_comments(options = {}, &block)
        request(:get, 'http://stream.meetup.com/2/event_comments', options, &block)
      end

      def before_request(&block)
        if block_given?
          @before_request = block
          self
        elsif instance_variable_defined?(:@before_request)
          @before_request
        else
          proc {}
        end
      end

    private

      def request(method, uri, params)
        before_request.call
        headers  = default_headers
        request  = HTTP::Request.new(method, uri + '?' + to_url_params(params), headers)
        response = Streaming::Response.new do |data|
          yield(data)
        end
        @connection.stream(request, response)
      end

      def to_url_params(params)
        params.collect do |param, value|
          [param, URI.encode(value)].join('=')
        end.sort.join('&')
      end

      def default_headers
        @default_headers ||= {
          :accept     => '*/*'
        }
      end

    end
  end
end

