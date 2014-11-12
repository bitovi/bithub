class Service < ActiveRecord::Base

  validates_presence_of :embed_id, :feed_name
  validate :json_config_valid

  belongs_to :embed

  def brand_identities
    self.brand.identities.where(:provider => feed_name).all
  end

  def brand
    self.embed.brand
  end

  def config
    @config ||= Services::ServiceConfig.new(json_config, feed_name)
  end

  def json_config_valid
    unless config.valid?
      errors.add(:json_config, config.error_msg)
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
