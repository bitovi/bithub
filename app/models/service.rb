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
  has_many :events

  after_create  { Guzzler::Client.schedule(decorated_for_crawler) }
  after_update  { Guzzler::Client.schedule(decorated_for_crawler) }
  after_destroy { Guzzler::Client.unschedule(decorated_for_crawler) }

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
      and service_entities.service_id = #{service_id};
    SQL

    ActiveRecord::Base.connection.execute(query)

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

  def decorated_for_crawler
    CrawlerServiceDecorator.new(self)
  end

  def config_with_credentials
    if brand_identity
      service_config.data.merge(brand_identity.credentials(property_id))
    else
      service_config.data
    end
  end

  def interval
    60
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

  ['disqus', 'facebook', 'foursquare', 'github', 'instagram', 'meetup', 'rss', 'stackexchange', 'tumblr', 'twitter', 'youtube'].each do |fn|
    define_method "is_#{fn}?" do
      fn ==  feed_name
    end
  end

end
