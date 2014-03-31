module Fetchers
  module Meetup

    class Rsvps
      def initialize(client)
        @client = client
      end

      def fetch
        params = @config.fetch(:params) { Hash.new }.merge({event_id: BootIds})
        @client.fetch(:rsvps, params)
      end
      
      BootIds = %w(139590042 158418582 160611832 138474582 153859552 158276872 159625482 139129072 139126722 151753432 143277702 139183712 139584132 139119232 157761792 140222352 161364162 149187962 140219242 139115132 154000522)
    end

  end
end
