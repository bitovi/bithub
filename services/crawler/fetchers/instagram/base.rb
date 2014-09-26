require 'instagram'

module Fetchers
  module Instagram

    class Base

      def initialize
        @client = create_client
      end

      def result
        @result
      end

      def client
        @client
      end

      private

      def create_client
        ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
      end

      def log_error(meta)
        Celluloid.logger.info " #{meta.code}: #{meta.error_type} #{meta.error_message}"
      end

      def publisher
        Celluloid::Actor[:publisher]
      end

    end

  end
end
