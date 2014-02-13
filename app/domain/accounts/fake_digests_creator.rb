class FakeDigestsCreator

  def initialize(i, oad)
    @identity = i
    @oauth_data = oad
  end
  
  def perform
    user = User.find_by_id(id)
    unless user.nil?
      user.send(method)
    end
  end

  def create_missing_repos_and_stars
    if provider == 'twitter'
      create_internal_follows
    elsif provider == 'github'
      create_internal_stars
    end
  end

  def create_custom_follows
    ApiCache.where(provider: provider, uid: uid_str).each do |res|
      data = {
        source_data: {
          uid: uid_from(@oauth_data),
          nickname: nickname_from(@oauth_data),
          target_screen_name: res.name,
          custom_follow: true,
        },
      }
      Dispatcher.new.dispatch(data, hint)
    end
  end

  def create_custom_stars
    ApiCache.where(provider: provider, uid: uid_str).each do |res|
      data = {
        source_data: {
          uid: uid_from(@oauth_data),
          nickname: nickname_from(@oauth_data),
          repo_name: res.name,
          custom_watch: true,
        }
      }
      Dispatcher.new.dispatch(data, hint)
    end
  end

  private

  def provider
    @identity.provider
  end

  def uid_str
    @identity.uid.to_s
  end

end
