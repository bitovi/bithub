class UserDecorator < Draper::Decorator
  delegate_all


  def roles
    source.roles.pluck(:name)
  end

  def avatar_url
    if !source.props['gravatar_url'].blank?
      source.props['gravatar_url']
    elsif source.identities && source.identities.map{|ident| ident.source_data['image'] if ident.source_data}.first
      source.identities.map{|ident| ident.source_data['image']}.first
    else
      '/assets/images/icon-user.png'
    end
  end

end
