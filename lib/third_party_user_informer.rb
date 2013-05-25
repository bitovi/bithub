class ThirdPartyUserInformer

  def initialize(env)
    env ||= ENV
    Twitter.configure do |config|
      config.consumer_key = env['TWITTER_CONSUMER_KEY']
      config.consumer_secret = env['TWITTER_CONSUMER_SECRET']
      config.oauth_token = env['TWITTER_OAUTH_TOKEN']
      config.oauth_token_secret = env['TWITTER_OAUTH_TOKEN_SECRET']
    end

    @github = Github.new(:client_id => env['GITHUB_CLIENT_ID'], :client_secret => env['GITHUB_CLIENT_SECRET'])
    @github.authorize_url(:redirect_uri => 'http://bithub.dev/api/auth/google/callback')
    token = @github.get_token()

    Github.configure do |config|
      config.oauth_token = token
    end
  end

  def fetch_from_twitter(user_query)
    Twitter.user_search(user_query)
  end

  def fetch_from_github
    @github.users.followers.following 'neektza'
  end
end
