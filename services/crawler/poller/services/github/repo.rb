module Supervisors::Services::Github
  class Repo < Supervisors::Service
    include Supervisors::Services::Github::Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('repo_activity', repo_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::RepoActivity.new(client, { user_repo: repo_name }),
          {interval: 60}
        ])

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('repo_issues', repo_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::RepoIssues.new(client, { user_repo: repo_name }),
          {interval: 600}
        ])

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('repo_issue_comments', repo_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::RepoPullRequests.new(client, { user_repo: repo_name }),
          {interval: 600}
        ])


      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('repo_pull_requests', repo_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::RepoIssuesComments.new(client, { user_repo: repo_name }),
          {interval: 300}
        ])


      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('repo_pull_request_comments', repo_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::RepoPullRequestsComments.new(client, { user_repo: repo_name }),
          {interval: 300}
        ])
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
