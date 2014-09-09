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
        { :key => static_config.fetch(:api_key) }
      end

      def static
        {
          :site => 'stackoverflow',
          :filter => static_config.fetch(:filter)
        }
      end

      private

      def static_config
        Celluloid::Actor[:configurator]
          .static_config
          .fetch(:stackexchange)
      end

    end
  end
end
