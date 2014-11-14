require 'github_api'

module Supervisors::Services
  class Github < Supervisors::Service

    def boot
      @client = ::Github.new(oauth_token: token)
      @endpoints = SupervisionGroup.new

      repos.each do |repo_name|
        repo_act_fetcher = Fetchers::Github::RepoActivity.new(
          @client, { user_repo: repo_name }
        )

        @endpoints.supervise_as(
          endpoint_actor_name('repo_activity', repo_name),
          Poller, *[
            @brand_name,
            @embed_name,
            repo_act_fetcher,
            {interval: 60}
          ]
        )

      #   @endpoints.supervise_as \
      #     actor_name('issues', repo_name),
      #     Poller,
      #     *[@brand_name, Fetchers::Github::RepoIssues.new(@client, {user_repo: repo_name}), {interval: 600}]

      #   @endpoints.supervise_as \
      #     actor_name('issues_comments', repo_name),
      #     Poller,
      #     *[@brand_name, Fetchers::Github::RepoPullRequests.new(@client, {user_repo: repo_name}), {interval: 600}]

      #   @endpoints.supervise_as \
      #     actor_name('pull_requests', repo_name),
      #     Poller ,
      #     *[@brand_name, Fetchers::Github::RepoIssuesComments.new(@client, {user_repo: repo_name}), {interval: 300}]

      #   @endpoints.supervise_as \
      #     actor_name('pull_requests_comments', repo_name),
      #     Poller,
      #     *[@brand_name, Fetchers::Github::RepoPullRequestsComments.new(@client, {user_repo: repo_name}), {interval: 300}]
      end

      orgs.each do |org_name|
        org_fetcher = Fetchers::Github::OrgActivity.new(
          @client,
          { org_name: org_name }
        )
        @endpoints.supervise_as(
          endpoint_actor_name(org_name , 'org_activity'),
          Poller, *[
            @brand_name,
            @embed_name,
            org_fetcher,
            {interval: 60}
          ]
        )
      end
    end

    private

    def token
      service_config.fetch(:access_token)
    end

    def repos
      service_config.fetch(:repos)
    end

    def orgs
      service_config.fetch(:orgs)
    end

    def endpoint_actor_name(endpoint_type, endpoint_id)
      (child_path(endpoint_type) + [endpoint_id]).join('_').to_sym
    end

    def user_stream?(endpoint_name)
      endpoint_name =~ /_user/
    end

  end
end
