module Identities
  module Builders
    class Disqus < Base

      DISQUS_API_DOMAIN = 'disqus.com'

      def initialize(args)
        super
        @conn = create_https_client
        self
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
        if new_credentials = fetch_access_token
          @data[:refreshed_credentials] = {
            access_token: new_credentials[:access_token],
            refresh_token: new_credentials[:refresh_token],
            expires_at: new_credentials['expires_in'] + expires_at
          }
        end
      end

      # Accessors

      def access_token
        credentials.fetch(:token)
      end

      def refresh_token
        credentials.fetch(:refresh_token)
      end

      def expires_at
        credentials.fetch(:expires_at)
      end

      def credentials
        @data[:refreshed_credentials] || oauth.fetch(:credentials)
      end

      def forums
        @data[:forums] || []
      end

      def forum_ids
        forums.map {|f| f['id']}
      end

      private

      def fetch_forums
        params = {
          limit: 100,
          user: oauth[:uid], #access_token: access_token,
          api_key: ENV['DISQUS_KEY']
        }
        path = "/api/3.0/users/listForums.json?" + URI.encode_www_form(params)

        response = @conn.get path

        if response.code == "200"
          JSON.parse(response.body)['response']
        else
          Rails.logger.error "Disqus, fetching forums failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end

      def fetch_access_token
        params = {
          grant_type: 'refresh_token',
          client_id: ENV['DISQUS_KEY'],
          client_secret: ENV['DISQUS_SECRET'],
          refresh_token: refresh_token
        }

        response = @conn.post "/api/oauth/2.0/access_token/", URI.encode_www_form(params)

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
