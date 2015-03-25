require 'rmeetup'

module Identities
  module BuilderStrategies
    class Meetup < Protocol
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

      def refresh_credentials
        if (creds = credentials_over_http)
          @data[:credentials] = {
            access_token: creds[:access_token],
            refresh_token: creds[:refresh_token],
            expires_at: Time.now.to_i + creds['expires_in']
          }
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

      def credentials_over_http
        params = {
          grant_type: 'refresh_token',
          client_id: ENV['MEETUP_KEY'],
          client_secret: ENV['MEETUP_SECRET'],
          refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token)
        }

        response = https_client(MEETUP_API_DOMAIN).post "/oauth2/access", URI.encode_www_form(params)

        if response.code == "200"
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        else
          fail "Meetup Identity Builder, refreshing access tokens failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end
    end
  end
end
