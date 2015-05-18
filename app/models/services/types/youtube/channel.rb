require 'google/api_client'

module Services
  module Types
    module Youtube
      class Channel
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :target, String
        attribute :display_name, String, :default => ''

        def target=(target)
          if channel_id = channel_id_from_url(target)
            self.id, self.display_name = channel_id_and_title_for_channel_id(channel_id)
          elsif user_id = user_id_from_url(target)
            self.id, self.display_name = channel_id_and_title_for_user_id(user_id)
          elsif /^[a-zA-Z0-9_-]*$/.match target
            self.id, self.display_name = channel_id_and_title_for_channel_id(target)
          end

          super target
        end

        private

        def channel_id_from_url(url)
          if res = /^http.?:\/\/.*youtube.com\/channel\/([^?\/]*)/.match(url)
            res[1]
          end
        end

        def user_id_from_url(url)
          if res = /^http.?:\/\/.*youtube.com\/user\/([^?\/]*)/.match(url)
            res[1]
          end
        end

        def channel_id_and_title_for_user_id(user_id)
          result = api_client.execute\
            :api_method => youtube_api.channels.list,
            :parameters => { part: 'id,snippet', forUsername: user_id }

          if chan = result.data.items.first
            [chan.id, chan.snippet['title']]
          end
        end

        def channel_id_and_title_for_channel_id(channel_id)
          result = api_client.execute\
            :api_method => youtube_api.channels.list,
            :parameters => { part: 'id,snippet', id: channel_id }

          if chan = result.data.items.first
            [chan.id, chan.snippet['title']]
          end
        end

        def api_client
          @client ||= Google::APIClient.new\
            application_name: 'Bithub',
            application_version: '0.0.1'

          @client.key           = ENV['GOOGLE_API_KEY']
          @client.authorization = nil

          @client
        end

        def youtube_api
          @youtube_api ||= api_client.discovered_api 'youtube', 'v3'
        end

      end
    end
  end
end
