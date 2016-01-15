module Guzzler::Fetchers

  module Stackexchange
    class Base
      include Protocol

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        handle_errors do
          pluck_items(HTTParty.get(url, :query => query))
        end
      end

      def pluck_items(resp)
        resp['items']
      end

      def query
        { 
          :tagged => @job.config.fetch(:tags).join(';'),
          :site => 'stackoverflow',
          :filter => Guzzler.static_config.fetch(:stackexchange).fetch(:filter),
          :key => Guzzler.static_config.fetch(:stackexchange).fetch(:api_key),
          :access_token => @job.token
        }
      end

      def url
        raise NotImplementedError
      end
    end
  end
end
