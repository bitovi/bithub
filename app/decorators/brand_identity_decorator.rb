class BrandIdentityDecorator < Draper::Decorator
  delegate_all

  def credentials
    {
      # access_token: source.access_token,
      # access_secret: nil
    }
  end

  def data
    provider = source.provider
    source_data = source.source_data
    data = Identities::Builders.const_get(provider.camel_case).new(source_data)

    provider_method = "provider_#{provider}".to_sym
    self.respond_to?(provider_method) ? self.send(provider_method, data) : {}
  end

  # private

  def provider_github(data)
    {
      access_token: data.access_token,
      repos: data.repo_names,
      orgs: data.org_names
    }
  end

  def provider_facebook(data)
    {
      access_token: data.access_token,
      pages: data.pages.map do |p|
        {id: p[:id], access_token: p[:access_token], name: p[:name]}
      end
    }
  end

  def provider_twitter(data)
    {
      access_token: data.access_token,
      access_secret: data.access_secret
    }
  end

  def provider_disqus(data)
    {
      access_token: data.access_token
    }
  end

  def provider_foursquare(data)
    {
      access_token: data.access_token
    }
  end

  def provider_meetup(data)
    {
      access_token: data.access_token
    }
  end

  def provider_stackexchange(data)
    {
      access_token: 
    }
  end
end
