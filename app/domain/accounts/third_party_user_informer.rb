module Accounts
  class ThirdPartyUserInformer
    attr_reader :github, :twitter

    class NotUIDException < Exception; end
    class NotUsernameException < Exception; end

    def initialize
      @twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
        config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
      end

      @github = Github.new({auto_pagination: true, basic_auth: 'neektza:ahn8Choo'})
    end

    def from_twitter(q)
      twitter.user_search(q)
    end

    def from_github(q)
      github.search.users(q).items
    end

    def follower_ids(screen_name)
      @twitter.follower_ids(screen_name).map{|id| id}
    end

    def stargazer_ids(repo, user = 'bitovi')
      @github.activity.starring.list(user, repo).map{|sg| sg.id}
    end

  end
end
