require 'rmeetup'

module Fetchers
  module Meetup

    class Events
      def initialize(client, opts)
        @client = client
        @interval = opts.fetch(:interval) { 10 }
        @events = opts.fetch(:events) { BootIds }
      end
      attr_reader :interval

      def fetch
        @client.fetch(:events, {sign: 'true', event_id: @events.join(',')})
      end

      BootIds = %w(139590042 158418582 160611832 138474582 153859552 158276872 159625482 139129072 139126722 151753432 143277702 139183712 139584132 139119232 157761792 140222352 161364162 149187962 140219242 139115132 154000522)
    end

  end
end
