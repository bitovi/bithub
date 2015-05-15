module Services
  module Types
    module Youtube
      class User
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :target, String
        attribute :display_name, String, :default => ''

        def target=(target)
          if user = user_from_url(target)
            self.id = user
            self.display_name = user
          elsif /^[a-zA-Z0-9_-]*$/.match target
            self.id = target
            self.display_name = target
          end

          super target
        end

        def user_from_url(url)
          if res = /^http.?:\/\/.*youtube.com\/user\/([^?\/]*)/.match(url)
            res[1]
          end
        end

      end
    end
  end
end
