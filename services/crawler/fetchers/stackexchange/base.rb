module Fetchers
  module Stackexchange

    class Base
      include Protocol

      def initialize(opts)
        @terms = opts.fetch(:terms)
        @token = opts.fetch(:token)
      end

      def fetch
        pluck_items(HTTParty.get url, :query => tagged\
          .merge(static)
          .merge(tagged)
          .merge(api_key)
          .merge(token))
      end

      def pluck_items(resp)
        resp['items']
      end

      def url
        raise NotImplementedError
      end

      def tagged
        { :tagged => @terms.join(';') }
      end

      def token
        { :access_token => @token }
      end

      def api_key
        { :key => Celluloid::Actor[:configurator]
          .static_config
          .fetch(:stackexchange)
          .fetch(:api_key) }
      end

      def static
        {
          :site => 'stackoverflow',
          :filter => '_GZ-2_GIz-dSc9CjKwGP4UEOutlPKHh*F)x8rj8B2kRb1dHxpaJFC5Upazs'
        }
      end
    end
  end
end

