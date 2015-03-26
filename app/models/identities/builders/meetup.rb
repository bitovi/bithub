require 'rmeetup'

module Identities
  module Builders
    class Meetup < Builder::Protocol
      MEETUP_API_DOMAIN = 'secure.meetup.com'

      def run
        groups
        self
      end

      def groups
        if gs = groups_via_http
          @storage[:groups] = groups_to_hashes(gs)
        end
      end

      private
      def groups_via_http
        client = RMeetup::Client.new :access_token => token
        client.fetch :groups, :member_id => @source_data.fetch(:uid)
      end


      def groups_to_hashes(groups)
        groups.map do |g|
          {
            id: g.id,
            name: g.name,
            link: g.link,
            urlname: g.urlname,
            timezone: g.timezone
          }
        end
      end

    end
  end
end
