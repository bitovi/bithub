class BrandIdentity < ActiveRecord::Base

  belongs_to :brand

  def config
    Identities::BrandIdentityConfig.new(source_data, provider_name)
  end
  alias_attribute :provider_name, :provider

end
