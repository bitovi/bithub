class BrandIdentity < ActiveRecord::Base
  belongs_to :brand
  has_many :services
  alias_attribute :provider_name, :provider

  def credentials(property_id = nil)
    facade.credentials(property_id)
  end

  def property_name_for_id(property_id)
    facade.property_name_for_id(property_id)
  end

  def property_id_name_pairs
    facade.property_id_name_pairs
  end
  
  def builder
    Identities::Builder.new(
      Identities::Builders.const_get(
        provider_name.camel_case, false),
      source_data)
  end

  def facade
    Identities::Facade.new(
      Identities::Facades.const_get(
        provider_name.camel_case, false),
      source_data, extracted_data)
  end
end
