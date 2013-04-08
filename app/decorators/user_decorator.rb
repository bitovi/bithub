class UserDecorator < Draper::Decorator
  delegate_all

  def avatar_url
    if !source.props['gravatar_url'].blank?
      source.props['gravatar_url']
    elsif source.identities.map{|ident| ident.source_data['image']}.first
      source.identities.map{|ident| ident.source_data['image']}.first
    else
      '/bithub-client/bithub/assets/images/icon-user.png'
    end
  end

end
