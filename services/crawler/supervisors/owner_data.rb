require 'supervisors/node_types'

class OwnerData < Struct.new(:brand, :embed, :service)

  def initialize(brand_id, brand_name, embed_id, embed_name, service_id, service_feed, service_type)

    brand   = BrandInfo.new brand_id.to_i, brand_name
    embed   = EmbedInfo.new embed_id.to_i, embed_name
    service = ServiceInfo.new service_id.to_i, service_feed, service_type

    super brand, embed, service
  end

  def to_s
    "#{brand} / #{embed} / #{service}"
  end
end
