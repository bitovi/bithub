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

    def followed_acct_ids(uid)
      fail NotUIDException unless uid.is_a? Integer
      Twitter::User.friend_ids(uid)
    end

    def watched_repo_names(username)
      fail NotUsernameException unless username.is_a? String
      res = github.activity.watching.watched :user => username
      res.response.body.map{|r| r['full_name']}
    end

    def followed_accts(uid)
      fail NotUIDException unless uid.is_a? Integer
      Twitter.friends(uid)
    end

    def watched_repos(username)
      fail NotUsernameException unless username.is_a? String
      res = github.activity.watching.watched({user: username})
      res.response.body
    end

  end
end
