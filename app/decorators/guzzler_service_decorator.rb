class GuzzlerServiceDecorator < Draper::Decorator
  delegate :id, :brand, :type_name, :feed_name, :listens?, :polls?

  def key
    "services:#{tenant_name}:#{service_id}"
  end

  def service_id
    id
  end

  def embed_id
    source.embed_id
  end

  def brand_id
    source.andand.embed.andand.brand.andand.id || source.brand_id
  end

  def tenant_name
    source.andand.embed.andand.brand.andand.tenant_name || source.tenant_name
  end

  def member
    'guzzler:' + key
  end

  def data
    {
      'config' => source.config_with_credentials,
      'interval' => source.interval,
      'feed_name' => source.feed_name,
      'type_name' => source.type_name,
      'brand_id' => brand_id,
      'embed_id' => embed_id,
      'service_id' => service_id

    }
  end
end
