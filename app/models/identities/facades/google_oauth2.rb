module Identities
  module Facades
    class GoogleOauth2 < Facade::Protocol

      def credentials(property_id = nil)
        { access_token: access_token, refresh_token: refresh_token }
      end

      def property_id_name_pairs(type)
        @extracted_data[type.to_sym] || []
      end

      def access_token
        tokens.fetch :access_token
      end

      def refresh_token
        tokens.fetch :refresh_token
      end

      private

      def tokens
        @extracted_data.fetch :tokens
      end

    end
  end
end
