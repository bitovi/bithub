module Services
  module Types
    module Youtube
      class Playlist
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :display_name, String, :default => ''

        def url=(url)
          if playlist_id = playlist_id_from_url(url)
            self.id = playlist_id
          end

          self.display_name = url
        end

        def playlist_id_from_url(url)
          uri = URI(url)

          if /.*youtube.com/.match(uri.host)
            if params = (uri.query && CGI::parse(uri.query))
              params['list'] && params['list'].first
            end
          end
        end

      end
    end
  end
end
