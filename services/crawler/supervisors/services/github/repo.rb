module Supervisors::Services::Github
  class Repo < Supervisors::Service
    include Supervisors::Services::Github::Common

    def boot
      @endpoints = SupervisionGroup.new

      repo_act_fetcher = Fetchers::Github::RepoActivity.new(
        client, { user_repo: repo_name })

      @endpoints.supervise_as(
        @path.child_actor_name("activty_#{repo_name}"),
        Poller, *[
          @path,
          repo_act_fetcher,
          {interval: 60}
        ]
      )

      if track_issues?
        repo_issues_fetcher =  Fetchers::Github::RepoIssues.new(
          client, { user_repo: repo_name })

        @endpoints.supervise_as(
          @path.child_actor_name("issues_#{repo_name}"),
          Poller, *[
            @path,
            repo_issues_fetcher,
            {interval: 600}
          ])

        iss_comm_fetcher = Fetchers::Github::RepoPullRequests.new(
          client, { user_repo: repo_name })

        @endpoints.supervise_as(
          @path.child_actor_name("issues_comments_#{repo_name}"),
          Poller, *[
            @path,
            iss_comm_fetcher,
            {interval: 600}
          ])
      end

      if track_pull_requests?
        pull_req_fetcher = Fetchers::Github::RepoIssuesComments.new(
          client, { user_repo: repo_name })

        @endpoints.supervise_as(
          @path.child_actor_name("pull_requests_#{repo_name}"),
          Poller, *[
            @path,
            pull_req_fetcher,
            {interval: 300}
          ])

        pull_req_comm_fetcher = Fetchers::Github::RepoPullRequestsComments.new(
          client, { user_repo: repo_name })

        @endpoints.supervise_as(
          @path.child_actor_name("pull_requests_comments#{repo_name}"),
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
      service_config.fetch(:tracking).fetch(:issues) { false }
    end

    def track_pull_requests?
      service_config.fetch(:tracking).fetch(:pull_requests) { false }
    end
  end
end
