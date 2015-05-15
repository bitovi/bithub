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
            self.id = channel_id
            self.display_name = target
          elsif /^[a-zA-Z0-9_-]*$/.match target
            self.id = target
          end

          super target
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
