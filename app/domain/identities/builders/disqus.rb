module Identities
  module Builders
    class Disqus < Base

      DISQUS_API_DOMAIN = 'disqus.com'

      def initialize(args)
        super
        boot
        @http = create_https_client
        self
      end

      def boot
        oauth_credentials = oauth.fetch(:credentials)
        @data[:credentials] = {
            access_token: oauth_credentials.fetch(:token),
            refresh_token: oauth_credentials.fetch(:refresh_token),
            expires_at: oauth_credentials.fetch(:expires_at)
        }
      end

      def build
        sync_forums
        @data
      end

      def sync_forums
        if forums = fetch_forums
          @data[:forums] = forums
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

      # Accessors

      def access_token
        credentials.fetch(:access_token)
      end

      def refresh_token
        credentials.fetch(:refresh_token)
      end

      def credentials
        @data.fetch(:credentials)
      end

      def forums
        @data[:forums] || []
      end

      def forum_names_and_ids
        forums.map do |f|
          {
            id: f['id'],
            name: f['name']
          }
        end
      end

      private

      def fetch_forums
        params = {
          limit: 100,
          user: oauth[:uid], #access_token: access_token,
          api_key: ENV['DISQUS_KEY']
        }
        path = "/api/3.0/users/listForums.json?" + URI.encode_www_form(params)

        response = @http.get path

        if response.code == "200"
          JSON.parse(response.body)['response']
        else
          Rails.logger.error "Disqus, fetching forums failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end

      def fetch_credentials
        params = {
          grant_type: 'refresh_token',
          client_id: ENV['DISQUS_KEY'],
          client_secret: ENV['DISQUS_SECRET'],
          refresh_token: refresh_token
        }

        response = @http.post "/api/oauth/2.0/access_token/", URI.encode_www_form(params)

        if response.code == "200"
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        else
          Rails.logger.error "Disqus, refreshing access tokens failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end

      def create_https_client(args={})
        domain = args[:domain] || DISQUS_API_DOMAIN

        http = Net::HTTP.new domain, 443
        http.use_ssl = true

        http
      end

    end
  end
end
