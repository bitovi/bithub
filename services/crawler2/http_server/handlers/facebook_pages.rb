module HttpServer
  module Handlers

    class FacebookPages
      include Celluloid

      def initialize
        Celluloid.logger.info "Started HTTP handler for Facebook Pages"
        @channels = {}
      end

      def handle(body)
        puts "==== Facebook handling something"
      end

      def register(brand, page_ids)
        @channels[brand] = page_ids
      end

      def unregister(brand)
        if channel = @channels[brand]
          @channel.delete brand
        end
      end

      def self.route
        '/facebook/pages'
      end
    end

  end
end
