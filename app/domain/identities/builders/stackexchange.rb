module Identities
  module Builders
    class Stackexchange < Base
      def access_token
        credentials.fetch(:token)
      end

      def credentials
        Rails.logger.info "++++++++++++++++++++++++++ #{@data.inspect}"
        @data.fetch(:oauth).fetch(:credentials)
      end
    end
  end
end
