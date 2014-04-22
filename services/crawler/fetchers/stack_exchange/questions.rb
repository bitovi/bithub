module Fetchers
  module StackExchange

    class Questions
      include Protocol

      def initialize(opts)
        @terms = opts.fetch(:terms)
        @static_params = {
          :site: 'stackoverflow',
          :filter: '_GZ-2_GIz-dSc9CjKwGP4UEOutlPKHh*F)x8rj8B2kRb1dHxpaJFC5Upazs'
        }
      end

      def fetch
        # http req
      end
    end
  end
end
