class UserDecorator < Draper::Decorator
  delegate_all

  def avatar_url
    if !source.props['gravatar_url'].blank?
      source.props['gravatar_url']
    else
      source.identities.map{|ident| ident.source_data['image']}.first
    end
  end

end
