module Services
  module Types
    module Facebook
      class PublicPage
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :url, String
        attribute :display_name, String, :default => ''

        def url=(url)
          if page = page_from_url(url)
            self.id = page['id']
            self.display_name = page['name']
          end

          super url
        end

        private

        def page_from_url(url)
          if page_name_or_id = page_name_or_id_from_url(url)
            graph_client.graph_call "v2.2/#{page_name_or_id}"
          end
        end

        def page_name_or_id_from_url(url)
          if res = /^http.?:\/\/.*facebook.com\/pages\/[^\/]*\/([^?\/]*)/.match(url)
            res[1]
          elsif res = /^http.?:\/\/.*facebook.com\/([^?\/]*)/.match(url)
            res[1]
          end
        end

        def graph_client
          @client ||= Koala::Facebook::API.new app_token
        end

        def app_token
          ENV['FACEBOOK_CLIENT_ID'] + '|' + ENV['FACEBOOK_CLIENT_SECRET']
        end

      end
    end
  end
end
