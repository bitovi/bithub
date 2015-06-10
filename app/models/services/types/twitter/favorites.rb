module Services
  module Types
    module Twitter
      class Favorites
        include Virtus.model(:strict => true)
        attribute :handle, String
        attribute :display_name, String, :default => lambda { |obj, attr| "\@#{obj.handle}" }
      end
    end
  end
end
