require 'github_api'

module FeedSupervisors
  class Github
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      @client = ::Github.new(oauth_token: token)
      boot
    end

    def boot
      Celluloid.logger.info "Booting Github supervisor for brand '#{@brand_name}'"
      @endpoints = SupervisionGroup.new

      repos.each do |repo_name|
        @endpoints.supervise_as \
          actor_name('repo_activity', repo_name),
          Poller,
          *[@brand_name, Fetchers::Github::RepoActivity.new(@client, {user_repo: repo_name}), {interval: 60}]

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
        @endpoints.supervise_as \
          actor_name(org_name , 'org_activity'),
          Poller,
          *[@brand_name, Fetchers::Github::OrgActivity.new(@client, {org_name: org_name}), {interval: 30}]
      end
    end

    private

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :github)
    end

    def token
      config.fetch(:access_token)
    end

    def repos
      config.fetch(:repos)
    end

    def orgs
      config.fetch(:orgs)
    end

    def actor_name(endpoint_type, endpoint_id)
      "#{@brand_name}_github_#{endpoint_type}_#{endpoint_id}".to_sym
    end

    def user_stream?(endpoint_name)
      endpoint_name =~ /_user/
    end

  end
end
