require 'github_api'

module Supervisors
  module Services
    class GithubRepo < Supervisors::Service

      def boot
        @client = ::Github.new(oauth_token: token)
        @endpoints = SupervisionGroup.new

        repo_act_fetcher = Fetchers::Github::RepoActivity.new(
          @client, { user_repo: repo_name })

        @endpoints.supervise_as(
          @path.child_actor_name("endpoint_activty_#{repo_name}"),
          Poller, *[
            @path,
            repo_act_fetcher,
            {interval: 60}
          ]
        )

        if track_issues?
          repo_issues_fetcher =  Fetchers::Github::RepoIssues.new(
            @client, { user_repo: repo_name })

          @endpoints.supervise_as(
            @path.child_actor_name("endpoint_issues_#{repo_name}"),
            Poller, *[
              @path,
              repo_issues_fetcher,
              {interval: 600}
            ])

          iss_comm_fetcher = Fetchers::Github::RepoPullRequests.new(
            @client, { user_repo: repo_name })

          @endpoints.supervise_as(
            @path.child_actor_name("enpoint_issues_comments_#{repo_name}"),
            Poller, *[
              @path,
              iss_comm_fetcher,
              {interval: 600}
            ])
        end

        if track_pull_requests?
          pull_req_fetcher = Fetchers::Github::RepoIssuesComments.new(
            @client, { user_repo: repo_name })

          @endpoints.supervise_as(
            @path.child_actor_name("endpoint_pull_requests_#{repo_name}"),
            Poller, *[
              @path,
              pull_req_fetcher,
              {interval: 300}
            ]) 

          pull_req_comm_fetcher = Fetchers::Github::RepoPullRequestsComments.new(
            @client, { user_repo: repo_name })

          @endpoints.supervise_as(
            @path.child_actor_name("endpoint_pull_requests_comments#{repo_name}"),
            Poller, *[
              @path,
              pull_req_comm_fetcher,
              {interval: 300}
            ])
        end

      end

      private

      def repo_name
        service_config.fetch(:name)
      end

      def track_issues?
        service_config.fetch(:tracking).fetch(:issues)
      end

      def track_pull_requests?
        service_config.fetch(:tracking).fetch(:pull_requests)
      end

      def endpoint_actor_name(endpoint_type, endpoint_id)
        (child_path(endpoint_type) + [endpoint_id]).join('_').to_sym
      end

      def user_stream?(endpoint_name)
        endpoint_name =~ /_user/
      end

    end
  end
end
