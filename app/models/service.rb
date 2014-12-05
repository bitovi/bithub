class Service < ActiveRecord::Base
  validates_presence_of :embed_id, :feed_name, :type_name
  validate :json_config_valid

  belongs_to :embed

  after_create :notify_service_start
  after_update :notify_service_reload
  after_destroy :notify_service_stop

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

  def notify_service_change(action)
    Support::CrawlerNotifier.new.notif({
      brand_name: embed.brand.name,
      embed_name: embed.name,
      service_info: "#{feed_name}+#{type_name}",
      action: action
    }) if config.valid?
  end

  private

  def notify_service_start
    notify_service_change(:start)
  end
  
  def notify_service_stop
    notify_service_change(:stop)
  end
  
  def notify_service_reload
    notify_service_change(:reload)
  end
end
