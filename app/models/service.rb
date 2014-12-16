class Service < ActiveRecord::Base
  validates_presence_of :embed_id, :feed_name, :type_name
  validate :service_config_validator

  belongs_to :embed
  has_and_belongs_to_many :entities

  after_create :notify_service_start
  after_destroy :notify_service_stop

  def brand_identities
    self.brand.identities.where(:provider => feed_name).all
  end

  def brand
    self.embed.brand
  end

  def service_config
    @config ||= Services::ServiceConfig.new(feed_name, type_name, config)
  end
  
  def make_link_to(entity)
    self.entities << entity
  end

  def credentials
    (bi = brand_identities.first) ? bi.config.data(:credentials) : {}
  end

  def config_valid
    unless service_config.valid?
      errors.add(:config, service_config.error_msg)
    end
  end

  def notify_service_change(action)
    Support::CrawlerNotifier.new.notif({
      brand_name: embed.brand.name,
      embed_name: embed.name,
      service_info: "#{feed_name}+#{type_name}",
      action: action
    }) if service_config.valid?
  end

  # private

  def notify_service_start
    notify_service_change(:start)
  end

  def notify_service_stop
    notify_service_change(:stop)
  end

  def notify_service_restart
    notify_service_change(:restart)
  end

  def notify_service_change(action)
    Support::CrawlerNotifier.new.notif({
      brand: { id: embed.brand.id, name: embed.brand.name },
      embed: { id: embed.id, name: embed.name },
      service: { id: id, feed_name: feed_name, type_name: type_name },
      signature: "service_#{action}",
      action: action
    }) if service_config.valid?
  end

  def service_config_validator
    unless service_config.valid?
      errors.add(:config, service_config.error_msg)
    end
  end
end
