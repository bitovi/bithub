module Fetchers
  module Github

    module Client
      def initialize(cfg)
        @config = cfg
        @client = Octokit::Client.new(access_token: @config.fetch(:data).fetch(:token))
      end
    end

  end
end
