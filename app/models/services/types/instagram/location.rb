module Services
  module Types
    module Instagram
      class Location
        include Virtus.model(:strict => true)
        attribute :id, String
      end
    end
  end
end
