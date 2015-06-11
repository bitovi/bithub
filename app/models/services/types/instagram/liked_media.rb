module Services
  module Types
    module Instagram
      class LikedMedia
        include Virtus.model(:strict => true)
        attribute :display_name, String, :default => ''
      end
    end
  end
end
