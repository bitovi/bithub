require 'rmeetup'

module Identities
  module BuilderStrategies
    class Meetup < Builder::StrategyProtocol
      MEETUP_API_DOMAIN = 'secure.meetup.com'

      def run
        extract_credentials
        fetch_groups
      end

      def extract_credentials
        @result[:credentials] = super.merge({
          refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token),
          expires_at: @source_data.fetch(:credentials).fetch(:expires_at)
        })
      end

      def fetch_groups
        if (groups = groups_via_http)
          @result[:groups] = groups_to_hashes(groups)
        end
      end

      private
      def groups_via_http
        client = RMeetup::Client.new :access_token => @source_data.fetch(:credentials).fetch(:token)
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
