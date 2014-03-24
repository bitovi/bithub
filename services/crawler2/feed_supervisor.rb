require_relative 'configurator'
require_relative 'poller'
require_relative 'streamer'
require_relative 'connectors/all'
require_relative 'fetchers/all'

class FeedSupervisor
  include Celluloid

  def initialize(feed_name)
    @feed_name = feed_name
    @config = Configurator.new(ENV['ENV']).config(@feed_name)
    boot
  end

  def boot
    endpoints_supervisor = SupervisionGroup.new

    polling_endpoints.each do |name, cfg|
      endpoints_supervisor.supervise_as(name, Poller, *[[@feed_name, name], cfg, fetchers(@feed_name, name, cfg)])
    end

    streaming_endpoints.each do |name, cfg|
      endpoints_supervisor.supervise_as name, Streamer, *[[@feed_name, name], cfg, connectors(@feed_name, name, cfg)]
    end
  end

  private

  def polling_endpoints
    @config[:polling] || []
  end

  def streaming_endpoints
    @config[:streaming] || []
  end

  def fetchers(feed_name, endpoint_name, endpoint_config)
    if feed_name == :github
      if endpoint_name.to_s =~ /activity/
        Fetchers::Github::RepoActivity
      elsif endpoint_name.to_s =~ /issues_comments/
        Fetchers::Github::RepoIssuesComments
      elsif endpoint_name.to_s =~ /pull_requests_comments/
        Fetchers::Github::RepoPullRequestsComments
      elsif endpoint_name.to_s =~ /issues/
        Fetchers::Github::RepoIssues
      elsif endpoint_name.to_s =~ /pull_requests/
        Fetchers::Github::RepoPullRequests
      end
    elsif feed_name == :meetup
      if endpoint_name == :open_events
        Fetchers::Meetup::OpenEvents
      elsif endpoint_name == :events
        Fetchers::Meetup::Events
      elsif endpoint_name == :rsvps
        Fetchers::Meetup::Rsvps
      end
    elsif feed_name == :twitter
      if endpoint_name == :tweet_search
        Fetchers::Twitter::TweetSearch
      end
    end
  end

  def connectors(feed_name, endpoint_name, endpoint_config) 
    if feed_name == :twitter
      if endpoint_name == :public
        Connectors::Twitter::Public
      elsif user_stream? endpoint_name
        Connectors::Twitter::User
      end
    elsif feed_name == :meetup
      if endpoint_name == :rsvps
        Connectors::Meetup::Rsvps
      elsif endpoint_name == :open_events
        Connectors::Meetup::OpenEvents
      end
    end
  end

  private
  def user_stream?(endpoint_name)
    endpoint_name =~ /_user/
  end
end
