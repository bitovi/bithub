namespace :data do
  desc "Fills API cache with followers/stargazers of importat accounts/repos."
  task :create_missing_digest_events => :environment do

    User.find_each do |user|

      user.identities.each do |ident|

        ApiCache.where(provider: ident.provider, uid: ident.uid.to_s).each do |res|

          type = (ident.provider == 'twitter') ? :custom_follow : :custom_watch
          name_name = (ident.provider == 'twitter') ? :target_screen_name : :repo_name

          data = HashWithIndifferentAccess.new({
            source_data: {
              uid: ident.uid,
              nickname: ident.nickname,
            }
          })

          data[:source_data][type] = true
          data[:source_data][name_name] = res.name

          Dispatcher.new.dispatch(data, ident.provider)
        end

      end
    end
  end
end
