require 'google/api_client'

module Identities
  module Builders
    class GoogleOauth2 < Builder::Protocol

      def run
        @storage[:tokens]    = tokens
        @storage[:channels]  = channels
        @storage[:playlists] = playlists

        self
      end

      private

      def tokens
        {
          refresh_token: refresh_token,
          access_token: token,
          expires_at: expires_at
        }
      end

      def channels
        fetch_youtube_channels.map do |c|
          {
            id: c.id,
            name: c.snippet.title
          }
        end
      end

      def playlists
        fetch_youtube_playlists.map do |p|
          {
            id: p.id,
            name: p.snippet.title
          }
        end
      end

      def expires_at
        credentials.fetch :expires_at
      end

      def refresh_token
        credentials.fetch :refresh_token
      end

      def client
        @client ||= Google::APIClient.new

        @client.authorization.access_token  = token
        @client.authorization.refresh_token = refresh_token
        @client.authorization.client_id     = ENV['GOOGLE_CLIENT_ID']
        @client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']

        @client
      end

      def youtube_api
        @youtube_api ||= client.discovered_api 'youtube', 'v3'
      end

      def fetch_youtube_channels
        result = client.execute\
          :api_method => youtube_api.channels.list,
          :parameters => { part: 'id,snippet', mine: true, maxResults: 50 }

        if result.error?
          error = result.data.error
          Rails.logger.warn "Fetching YouTube channels for #{@source_data['name']} failed with:  #{error['code']}, #{error['message']}"
        end

        result.data.items
      end

      def fetch_youtube_playlists()
        result = client.execute\
          :api_method => youtube_api.playlists.list,
          :parameters => { part: 'id,snippet', mine: true, maxResults: 50 }

        if result.error?
          error = result.data.error
          Rails.logger.warn "Fetching YouTube playlists for #{@source_data['name']} failed with:  #{error['code']}, #{error['message']}"
        end

        result.data.items
      end

    end
  end
end
