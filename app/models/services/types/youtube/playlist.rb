module Services
  module Types
    module Youtube
      class Playlist
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :target, String
        attribute :display_name, String, :default => ''

        def target=(target)
          if playlist_id = playlist_id_from_url(target)
            self.id = playlist_id
            self.display_name = target
          elsif /^[a-zA-Z0-9_-]*$/.match target
            self.id = target
          end

          super target
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
