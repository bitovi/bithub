class Service < ActiveRecord::Base
  include Traits::AmqpDeclaration

  validates_presence_of :embed_id, :feed_name, :type_name
  validate :service_config_validator

  belongs_to :embed

  has_many :service_entities
  has_many :entities, through: :service_entities

  has_many :service_errors

  after_create  { notify_crawler(:start) }
  after_update  { notify_crawler(:restart) }
  after_destroy { notify_crawler(:stop) }

  def brand_identities
    self.brand.identities.where(:provider => feed_name).all
  end

  def clear_linked_entities
    links = ServiceEntity.where(service_id: id).all 
    links.each do |l|
      l.entity.destroy if l.entity.has_only_one_service?
      l.destroy
    end
  end

  def has_errors?
    service_errors.present?
  end

  def entity_count
    entities.count
  end

  def brand
    self.embed.brand
  end

  def service_config
    @config ||= Services::ServiceConfig.new(feed_name, type_name, config)
  end

  def humanize
    (bi = brand_identities.first) ? service_config.humanize(bi) : nil
    self.config = service_config.data
  end

  def make_link_to(entity)
    self.entities << entity
  end

  def credentials(argument = nil)
    (bi = brand_identities.first) ? bi.config.credentials(argument) : {}
  end

  # private

  def service_config_validator
    unless service_config.valid?
      errors.set(:config_attrs, service_config.error_msg)
    end
  end

  def notify_crawler(action)
    if ENV['RAILS_ENV'] != 'test' && service_config.valid?
      Rails.logger.info "Publishing a command to crawler #{msg(action)}"
      payload = JSON.generate(msg(action))
      x('x.crawler').publish(payload, routing_key: :config)
    end
  end

  def msg(action)
    {
      brand: {
        id: embed.brand.id,
        name: embed.brand.name
      },
      embed: {
        id: embed.id,
        name: embed.name
      },
      service: {
        id: id,
        feed_name: feed_name,
        type_name: type_name,
        config: service_config.data
      },
      signature: "service_#{action}",
      action: action
    }
  end
end
