require 'supervisors/node_types'

class OwnerData

  def initialize(
    brand_id,
    brand_name,
    embed_id,
    embed_name,
    service_id,
    service_feed,
    service_type
  )

    @brand   = BrandInfo.new brand_id.to_i, brand_name
    @embed   = EmbedInfo.new embed_id.to_i, embed_name
    @service = ServiceInfo.new service_id.to_i, service_feed, service_type
  end
  attr_reader :brand, :embed, :service

  def to_s
    "#{@brand} / #{@embed} / #{@service}"
  end
end
