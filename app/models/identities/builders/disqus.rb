module Identities
  module Builders
    class Disqus < Builder::Protocol
      DISQUS_API_DOMAIN = 'disqus.com'

      def run
        credentials
        forums
        self
      end

      def credentials
        @storage[:credentials] = super.merge({
          refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token),
          expires_at: @source_data.fetch(:credentials).fetch(:expires_at)
        })
      end

      def forums
        if fs = forums_over_https
          @storage[:forums] = fs
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
