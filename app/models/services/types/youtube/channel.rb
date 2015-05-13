module Services
  module Types
    module Youtube
      class Channel
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :display_name, String, :default => ''

        def url=(url)
          if channel_id = channel_id_from_url(url)
            self.id = channel_id
          end

          self.display_name = url
        end

        def channel_id_from_url(url)
          if res = /^http.?:\/\/.*youtube.com\/channel\/([^?\/]*)/.match(url)
            res[1]
          end
        end

      end
    end
  end
end
