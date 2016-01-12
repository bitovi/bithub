require 'github_api'
require_relative 'common'

module Guzzler
  module Fetchers

    module Github
      class RepoActivity
        include Protocol
        include Github::Common

        def initialize(job)
          @job = job
        end

        def fetch
          log_fetch

          handle_errors(@job) do
            client.activity.events.auto_pagination = false
            client.activity.events.repos(user: user_name, repo: repo_name)
          end
        end

        def initial_fetch
          handle_errors(@job) do
            client.activity.events.auto_pagination = true
            client.activity.events.repos(user: user_name, repo: repo_name)
          end
        end

        private

        def user_name
          @user_name ||= @job.config.fetch('name').split('/').first
        end

        def repo_name
          @repo_name ||= @job.config.fetch('name').split('/').last
        end
      end
    end
  end
end
