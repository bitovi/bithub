namespace :data do
  desc "Fills API cache with followers/stargazers of importat accounts/repos."
  task :fill_api_cache => :environment do

    api = Accounts::ThirdPartyUserInformer.new
    important_accounts = Tag.tagged_with('req_friends').all
    important_repos = Tag.tagged_with('req_favourites').all

    important_repos.each do |repo|
      ids = api.stargazer_ids(repo.name).map{|uid| uid.to_s}.each do |uid|
        ApiCache.create({name: repo.name, uid: uid, provider: 'github'})
      end
    end

    # important_accounts.each do |acct|
    #   ids = api.follower_ids(acct.name).map{|uid| uid.to_s}.each do |uid|
    #     ApiCache.create({name: acct.name, uid: uid, provider: 'twitter'})
    #   end
    # end
  end
end
