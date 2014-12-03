class Service < ActiveRecord::Base

  validates_presence_of :embed_id, :feed_name, :type_name
  validate :config_valid

  belongs_to :embed

  def brand_identities
    self.brand.identities.where(:provider => feed_name).all
  end

  def brand
    self.embed.brand
  end

  def service_config
    @config ||= Services::ServiceConfig.new(feed_name, type_name, config)
  end

  def config_valid
    unless service_config.valid?
      errors.add(:config, service_config.error_msg)
    end
  end

  def notify_crawler
    if config.valid?
      Support::CrawlerNotifier.new.notif({
        brand_name: brand.name,
        feed_name: feed_name,
        action: :restart
      })
    end
  end
end

# after_update :notify_crawler
# after_create :notify_crawler
