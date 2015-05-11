module Services
  module Types
    module Youtube
      class User
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :display_name, String, :default => ''
      end
    end
  end
end
