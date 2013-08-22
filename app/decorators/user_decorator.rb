class UserDecorator < Draper::Decorator
  delegate_all

  def roles
    source.roles.pluck(:name)
  end

  def avatar_url
    url = '/assets/images/icon-user.png'

    if !source.props['gravatar_url'].blank?
      url = source.props['gravatar_url']
    else
      # github -> 'avatar_url', twitter -> 'profile_image_url'
      image_attrs = ['avatar_url', 'profile_image_url']
      source.identities.each do |ident|
        image_attrs.each {|attr| url = ident['source_data'][attr] if ident['source_data'] && ident['source_data'][attr] }
      end
    end

    url
  end

end
