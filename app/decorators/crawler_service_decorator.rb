class CrawlerServiceDecorator < Draper::Decorator
  delegate :id, :brand

  def key
    "services:#{source.brand.tenant_name}:#{source.id}"
  end

  def member
    'guzzler:' + key
  end

  def data
    {
      'config' => source.config_with_credentials,
      'interval' => source.interval
    }
  end
end
