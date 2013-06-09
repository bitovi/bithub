class ThirdPartyUserInformer

  def initialize
    Twitter.configure do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end

    @github = Github.new basic_auth: 'neektza:ahn8Choo'
  end

  def from_twitter(q)
    Twitter.user_search(q)
  end

  def from_github(q)
    res = @github.search.users(q)
    res.users
  end
end
