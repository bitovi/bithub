require_relative 'common'

module Guzzler::Fetchers
  module Github
    module Common

      def client
        @client ||= ::Github.new(oauth_token: @job.token)
      end

    end
  end
end
