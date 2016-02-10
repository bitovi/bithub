class Service < ActiveRecord::Base
  attr_accessor :skip_callbacks_during_testing

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

  after_create :guzzle_service, :unless => :skip_callbacks_during_testing
  after_update :guzzle_service, :unless => :skip_callbacks_during_testing
  after_destroy :unguzzle_service, :unless => :skip_callbacks_during_testing

  scope :feed, ->(fn) { where(feed_name: fn) }
  scope :type, ->(tn) { where(type_name: tn) }

  QUERIES_FOR_LISTENING_SERVICES = [
    Service.joins(:embed => :brand).where(feed_name: %w(instagram foursquare)),
    Service.joins(:embed => :brand).where(feed_name: 'facebook', type_name: 'page')
  ]

  QUERIES_FOR_POLLING_SERVICES = [
    Service.joins(:embed => :brand).where(feed_name: %w(github meetup twitter rss disqus stackexchange tumblr youtube)),
    Service.joins(:embed => :brand).where(feed_name: 'facebook', type_name: 'public_page')
  ]

  def self.all_services(type)
    Brand.map_tenants_to do
      "Service::QUERIES_FOR_#{type.to_s.upcase}_SERVICES".constantize.map do |q|
        q.select('services.*, brands.tenant_name as tenant_name').to_a
      end.flatten
    end.flatten
  end

  def self.num_of_services(type)
    Brand.map_tenants_to do
      "Service::QUERIES_FOR_#{type.to_s.upcase}_SERVICES".constantize.map do |q|
        q.count
      end.sum
    end.sum
  end

  def guzzle_service
    Guzzler::Client.guzzle(GuzzlerServiceDecorator.new(self))
  end

  def unguzzle_service
    Guzzler::Client.unguzzle(GuzzlerServiceDecorator.new(self))
  end

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
    service_entities.create(entity: entity)
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

  def listens?
    feed_name == 'instagram' || feed_name == 'foursquare' || (feed_name == 'facebook' && type_name == 'page')
  end

  def polls?
    !listens?
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
