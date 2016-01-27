require_relative 'common'

module Guzzler
  module Fetchers
    module Github
      module Common

        def client
          @client ||= ::Github.new(oauth_token: @service.token)
        end

      end
    end
  end
end
