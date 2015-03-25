module Identities
  class Builder
    module Strategies
      class Disqus < Identities::Builder::Protocol

        def extract_credentials
          @result[:credentials] = super.merge({
            refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token),
            expires_at: @source_data.fetch(:credentials).fetch(:expires_at)
          })
        end

        def fetch_forums
          if forums = forums_over_http
            @result[:forums] = forums
          end
        end

        def refresh_credentials
          if (creds = credentials_over_http)
            @result[:credentials] = {
              access_token: creds.fetch(:access_token),
              refresh_token: creds.fetch(:refresh_token),
              expires_at: Time.now.to_i + creds.fetch[:expires_in]
            }
          end
        end

        private
        def forums_over_http
          params = {
            limit: 100,
            user: @source_data[:uid],
            api_key: ENV['DISQUS_CLIENT_ID']
          }

          path = "/api/3.0/users/listForums.json?" + URI.encode_www_form(params)

          response = https_client.get path

          if response.code == "200"
            JSON.parse(response.body)['response']
          else
            Rails.logger.error "Disqus, fetching forums failed with #{response.code} #{response.body.inspect}"
            nil
          end
        end

        def credentials_over_http
          params = {
            grant_type: 'refresh_token',
            client_id: ENV['DISQUS_CLIENT_ID'],
            client_secret: ENV['DISQUS_CLIENT_SECRET'],
            refresh_token: @source_data.fetch(:credentials).fetch(:refresh_token)
          }

          response = https_client.post "/api/oauth/2.0/access_token/", URI.encode_www_form(params)

          if response.code == "200"
            HashWithIndifferentAccess.new(JSON.parse(response.body))
          else
            Rails.logger.error "Disqus, refreshing access tokens failed with #{response.code} #{response.body.inspect}"
            nil
          end
        end

        DISQUS_API_DOMAIN = 'disqus.com'
        def https_client
          if !@https_client 
            http = Net::HTTP.new DISQUS_API_DOMAIN, 443
            http.use_ssl = true
            @https_client = http
          else
            @https_client
          end
        end
      end
    end
  end
end
