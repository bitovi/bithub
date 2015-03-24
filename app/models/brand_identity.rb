class BrandIdentity < ActiveRecord::Base

  belongs_to :brand

  def config
    Identities::BrandIdentityConfig.new(source_data, provider_name)
  end
  alias_attribute :provider_name, :provider

  def credentials(property_id = nil)
    config.credentials(property_id)
  end
end
