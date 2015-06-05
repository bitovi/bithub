require 'supervisors/node_types/node_types'

class OwnerData

  def initialize(
    brand_id\
    , brand_name\
    , embed_id\
    , embed_name\
    , service_id\
    , service_feed\
    , service_type\
    , service_config\
  )

    @brand   = NodeTypes::BrandInfo.new brand_id.to_i, brand_name
    @embed   = NodeTypes::EmbedInfo.new embed_id.to_i, embed_name
    @service = NodeTypes::ServiceInfo.new service_id.to_i, service_feed, service_type, service_config
  end
  attr_reader :brand, :embed, :service

  def to_s
    "#{@brand} / #{@embed} / #{@service}"
  end

  def to_h
    {
      brand_id: @brand.id,
      brand_name: @brand.name,
      embed_id: @embed.id,
      embed_name: @embed.name,
      service_id: @service.id,
      feed_name: @service.feed_name,
      type_name: @service.type_name
    }
  end

  def to_log_format
    "#{@brand.id},#{@embed.id},#{@service.id},#{service.feed_name},#{@service.type_name}"
  end
end
