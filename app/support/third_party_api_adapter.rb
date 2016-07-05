module Support
  class ThirdPartyApiAdapter
    attr_reader :github, :twitter

    class NotUIDException < Exception; end
    class NotUsernameException < Exception; end
    class ResponseNot200 < Exception; end

    def twitter
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV.fetch('TWITTER_CLIENT_ID')
        config.consumer_secret = ENV.fetch('TWITTER_CLIENT_SECRET')
        config.access_token = ENV.fetch('TWITTER_ACCESS_TOKEN')
        config.access_token_secret = ENV.fetch('TWITTER_ACCESS_TOKEN_SECRET')
      end
    end

    def github
      @github ||= Github.new(
        client_id: ENV.fetch('GITHUB_CLIENT_ID'),
        client_secret: ENV.fetch('GITHUB_CLIENT_SECRET')
      ) do |config|
        config.auto_pagination = true
      end
    end

    def user_from_instagram(q, brand_identity)
      Instagram.user_search(q, {
        access_token: brand_identity.credentials.fetch(:access_token)
      })
    end

    def user_from_twitter(q)
      twitter.user_search(q)
    end

    def user_from_github(q)
      github.search.users(q).items
    end

    def user_from_twitter_by_uid(uid)
      @twitter.user(uid).andand.to_h.symbolize_keys
    end

    def user_from_github_by_uid(uid)
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
