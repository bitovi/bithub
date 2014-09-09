class UserDecorator < Draper::Decorator
  delegate_all

  def roles
    source.roles.pluck(:name)
  end

  def score
    self.total_score
  end

  def reduced_identities
    source.identities.map do |i|
      {
        provider: i.provider,
        uid: i.uid,
        name: i.name,
        username: i.nickname,
        profile_url: i.profile_url
      }
    end
  end

end
