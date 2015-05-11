module Identities
  module Facades
    class GoogleOauth2 < Facade::Protocol

      def property_id_name_pairs(type)
        @extracted_data[type.to_sym] || []
      end

    end
  end
end
