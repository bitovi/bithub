module Identities
  module BuilderStrategies
    class Disqus < Builder::StrategyProtocol
      DISQUS_API_DOMAIN = 'disqus.com'

      def run
        extract_credentials
        fetch_forums
      end

      def extract_credentials
        @result[:credentials] = super.merge({
          refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token),
          expires_at: @source_data.fetch(:credentials).fetch(:expires_at)
        })
      end

      def fetch_forums
        if forums = forums_over_https
          @result[:forums] = forums
        end
      end

      private
      def forums_over_https
        params = {
          limit: 100,
          user: @source_data[:uid],
          api_key: ENV['DISQUS_CLIENT_ID']
        }

        path = "/api/3.0/users/listForums.json?" + URI.encode_www_form(params)
        response = https_client(DISQUS_API_DOMAIN).get path

        if response.code == "200"
          JSON.parse(response.body)['response'].map{|f| HashWithIndifferentAccess.new(f)}
        else
          fail "Fetching Disqus forums failed with #{response.code} #{response.body.inspect}"
          nil
        end
      end
    end
  end
end
