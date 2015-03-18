module Services
  module Types
    class HashlessString < Virtus::Attribute
      def coerce(value)
        value.gsub(/[^\w|-]/,'')
      end
    end
  end
end
