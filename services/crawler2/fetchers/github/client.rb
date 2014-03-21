require 'octokit'

module Fetchers
  module Github

    module Client
      def initialize(cfg)
        @config = cfg

        @client = Octokit::Client.new(access_token: @config.fetch(:token))
        @repo = @config.fetch(:repo)
      end
    end

  end
end
