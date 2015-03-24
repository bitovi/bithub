module Services
  module Types
    module Instagram
      class Geography
        include Virtus.model(:strict => true)
        attribute :lat, String
        attribute :lng, String
        attribute :radius, String
      end
    end
  end
end
