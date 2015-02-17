require 'rmeetup'

module Identities
  module Builders
    class Meetup < Base

      MEETUP_API_DOMAIN = 'secure.meetup.com'

      def initialize(args)
        super
        @http_client = create_https_client

        oauth_credentials = oauth.fetch(:credentials)
        @data[:credentials] = {
          access_token: oauth_credentials.fetch(:token),
          refresh_token: oauth_credentials.fetch(:refresh_token),
          expires_at: oauth_credentials.fetch(:expires_at)
        }
      end
      
      def group_name(group_id)
        groups.find do |g|
          g['id'].to_s == group_id.to_s
        end['name']
      end
      
      def build
        sync_groups
        @data
      end
      
      def boot
      end

      def sync_groups
        # rmeetup response lacks of #to_hash
        @data[:groups] = fetch_groups.map do |g|
          {
            id: g.id,
            name: g.name,
            link: g.link,
            urlname: g.urlname,
            timezone: g.timezone
          }
        end
      end

      def refresh_credentials
        if new_credentials = fetch_credentials
          @data[:credentials] = {
            access_token: new_credentials[:access_token],
            refresh_token: new_credentials[:refresh_token],
            expires_at: Time.now.to_i + new_credentials['expires_in']
          }
        end
      end

      def suggestions(type=nil)
        group_names_and_ids
      end

      def credentials(argument = nil)
        { access_token: access_token }
      end

      # Accessors

      def groups
        @data[:groups]
      end

      def group_names_and_ids
        groups.map do |g|
          {
            id: g['id'],
            name: g['urlname']
          }
        end
      end

      def uid
        oauth.fetch(:uid)
      end

      def access_token
        @data.fetch(:credentials).fetch(:access_token)
      end

      def refresh_token
        @data.fetch(:credentials).fetch(:refresh_token)
      end

      private

      def fetch_access_token
        domain = args[:domain] || DISQUS_API_DOMAIN

        http = Net::HTTP.new domain, 443
        http.use_ssl = true

      end

      def fetch_groups
        client = RMeetup::Client.new :access_token => access_token
        client.fetch :groups, :member_id => uid
      end

      def fetch_credentials
        params = {
          grant_type: 'refresh_token',
          client_id: ENV['MEETUP_KEY'],
          client_secret: ENV['MEETUP_SECRET'],
          refresh_token: refresh_token
        }

        response = @http_client.post "/oauth2/access", URI.encode_www_form(params)

        if response.code == "200"
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        else
          Rails.logger.error "Meetup, refreshing access tokens failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end

      def create_https_client(args={})
        domain = args[:domain] || MEETUP_API_DOMAIN

        http = Net::HTTP.new domain, 443
        http.use_ssl = true

        http
      end

    end
  end
end
