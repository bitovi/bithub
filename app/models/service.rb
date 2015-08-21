class Service < ActiveRecord::Base
  include RabbitHelper::Sugar

  validates_presence_of :embed_id, :feed_name, :type_name
  validate :service_config_validator
  validate :service_state_validator

  belongs_to :embed
  belongs_to :brand_identity
  alias_method :bi, :brand_identity

  has_many :service_entities
  has_many :entities, through: :service_entities

  has_many :service_errors
  has_many :events, dependent: :delete_all

  after_create  { notify_crawler(:start) }
  after_update  { notify_crawler(:restart) }
  after_destroy { notify_crawler(:stop) }

  scope :feed, ->(fn) { where(feed_name: fn) }
  scope :type, ->(tn) { where(type_name: tn) }

  def brand
    embed.brand
  end

  def clear_relations_and_destroy
    service_id = id
    embed_id = embed.id

    query = <<-SQL
      delete from embed_entities using service_entities
      where embed_entities.entity_id = service_entities.entity_id
      and embed_id = #{embed_id}
      and service_id = #{service_id};
      -- ^ delete connections between entities belonging to the service
      -- we're currently deleting and the embed that service belongs to

      delete from service_entities
      where service_id = #{service_id};
      -- ^ delete connections between entities
      -- and the service we're deleting

      delete from entities
      where not exists (
        select 1 from service_entities se
        where se.entity_id = entities.id
      );
      -- ^ delete entities that have
      -- no connections to a service

      delete from events
      where service_id = #{service_id};
      -- ^ delete events that belong to this service
    SQL

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(query)
    end

    destroy
  end

  def mark_as_loaded
    self.update_column(:state, 'loaded') #update_column skips callbacks, and it should be that way!
  end

  def has_errors?
    service_errors.present?
  end

  def property_id
    service_config.property_id
  end

  def service_config
    @config ||= Services::ServiceConfig.new(self)
  end

  def humanized_config
    self.config = service_config.humanized_config
  end

  def make_link_to(entity)
    self.entities << entity
  end

  def config_with_credentials
    if brand_identity
      service_config.data.merge(brand_identity.credentials(property_id))
    else
      service_config.data
    end
  end

  # private

  def service_config_validator
    unless service_config.valid?
      errors.set(:config_attrs, service_config.error_msg)
    end
  end

  def service_state_validator
    unless %w(loading loaded).include?(state)
      errors.set(:state, "can either be 'loading' or 'loaded'")
    end
  end

  def notify_crawler(action)
    if ENV['RAILS_ENV'] != 'test' && service_config.valid?
      Rails.logger.info "Publishing a command to crawler #{msg(action)}"
      payload = JSON.generate(msg(action))
      x('x.crawler', chan_is_short_lived = true) do |xchange|
        xchange.publish(payload, routing_key: :config)
      end
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
        config: config_with_credentials
      },
      signature: "service_#{action}",
      action: action
    }
  end

  ['disqus', 'facebook', 'foursquare', 'github', 'instagram', 'meetup', 'rss', 'stackexchange', 'tumblr', 'twitter', 'youtube'].each do |fn|
    define_method "is_#{fn}?" do
      fn ==  feed_name
    end
  end

end
