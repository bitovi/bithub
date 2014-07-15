require 'identities/builders'

class BrandIdentityDecorator < ::Draper::Decorator
  delegate :id, :brand, :uid, :provider

  def data
    @builder = ::Identities::Builders\
      .const_get(source.provider.camel_case)\
      .new(source.source_data)

    provider_method = "provider_#{source.provider}".to_sym
    respond_to?(provider_method) ? self.send(provider_method) : {}
  end

  def provider_github
    {
      info: @builder.info,
      access_token: @builder.access_token,
      repos: @builder.repo_names,
      orgs: @builder.org_names
    }
  end

  def provider_facebook
    {
      info: @builder.info,
      access_token: @builder.access_token,
      pages: @builder.pages.map do |p|
        {id: p[:id], access_token: p[:access_token], name: p[:name]}
      end
    }
  end

  def provider_twitter
    {
      info: @builder.info,
      access_token: @builder.access_token,
      access_secret: @builder.access_secret
    }
  end

  def provider_disqus
    {
      info: @builder.info,
      access_token: @builder.access_token,
      forums: @builder.forum_names_and_ids
    }
  end

  def provider_foursquare
    {
      info: @builder.info,
      access_token: @builder.access_token
    }
  end

  def provider_meetup
    {
      info: @builder.info,
      access_token: @builder.access_token,
      groups: @builder.group_names_and_ids
    }
  end

  def provider_stackexchange
    {
      info: @builder.info,
      access_token: @builder.access_token
    }
  end
end
