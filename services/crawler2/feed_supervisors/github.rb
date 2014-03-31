require 'github_api'

module FeedSupervisors
  class Github
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @config = cfg
      @client = ::Github.new(oauth_token: @config.fetch(:token))
      boot
    end

    def boot
      Celluloid.logger.info "Booting Github supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      repos.each do |repo_name|
        @endpoints.supervise_as(actor_name('repo_activity', repo_name)          , Poller , *[{user_repo: repo_name}, @client, Fetchers::Github::RepoActivity])
        @endpoints.supervise_as(actor_name('issues', repo_name)                 , Poller , *[{user_repo: repo_name}, @client, Fetchers::Github::RepoIssues])
        @endpoints.supervise_as(actor_name('issues_comments', repo_name)        , Poller , *[{user_repo: repo_name}, @client, Fetchers::Github::RepoPullRequests])
        @endpoints.supervise_as(actor_name('pull_requests', repo_name)          , Poller , *[{user_repo: repo_name}, @client, Fetchers::Github::RepoIssuesComments])
        @endpoints.supervise_as(actor_name('pull_requests_comments', repo_name) , Poller , *[{user_repo: repo_name}, @client, Fetchers::Github::RepoPullRequestsComments])
      end

      orgs.each do |org_name|
        @endpoints.supervise_as(actor_name(org_name , 'org_activity') , Poller , *[{org_name: org_name}, @client, Fetchers::Github::OrgActivity])
      end
    end

    private
    def repos
      @config.fetch(:repos)
    end

    def orgs
      @config.fetch(:orgs)
    end
    
    def actor_name(endpoint_type, endpoint_id)
      "#{@brand_name}_github_#{endpoint_type}_#{endpoint_id}".to_sym
    end

    def user_stream?(endpoint_name)
      endpoint_name =~ /_user/
    end

  end
end

