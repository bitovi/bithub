module Accounts
  class ThirdPartyUserInformer
    attr_reader :github, :twitter

    class NotUIDException < Exception; end
    class NotUsernameException < Exception; end
    class ResponseNot200 < Exception; end

    GITHUB_USERNAME = 'neektza'
    GITHUB_PASSWORD = 'ahn8Choo'

    def initialize
      @twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
        config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
      end

      @github = Github.new do |config|
        config.auto_pagination = true
        config.basic_auth      = "#{GITHUB_USERNAME}:#{GITHUB_PASSWORD}"
      end
    end
    attr_reader :twitter, :github

    def from_twitter(q)
      twitter.user_search(q)
    end

    def from_github(q)
      github.search.users(q).items
    end

    def from_twitter_by_uid(uid)
      @twitter.user(uid).andand.to_h.symbolize_keys
    end

    def from_github_by_uid(uid)
      # Github API offically doesn't support fetching users by id
      # that's why we make 'manual' HTTP req.

      http = Net::HTTP.new("api.github.com",443)
      req = Net::HTTP::Get.new("/user/#{uid}")
      http.use_ssl = true
      req.basic_auth GITHUB_USERNAME, GITHUB_PASSWORD
      response = http.request(req)

      raise ResponseNot200, "HTTP #{response.code}" if !response.code.match(/2../)

      YAML::load(response.body).andand.symbolize_keys
    end

    def follower_ids(screen_name)
      @twitter.follower_ids(screen_name).map{|id| id}
    end

    def stargazer_ids(repo, user = 'bitovi')
      @github.activity.starring.list(user, repo).map{|sg| sg.id}
    end

  end
end
