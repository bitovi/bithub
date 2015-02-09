class Embed < ActiveRecord::Base
  include Traits::AmqpDeclaration

  belongs_to :brand
  validates_uniqueness_of :name, :scope => [:brand_id]

  has_many :filters, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :presets, :class_name => "EmbedPreset"

  has_many :embed_entities
  has_many :entities, through: :embed_entities

  has_many :waitlisted_entities, -> { where is_approved: false },
    through: :embed_entities,
    class_name: 'EmbedEntity',
    source: :entity

  has_many :approved_entities, -> { where is_approved: true },
    through: :embed_entities,
    class_name: 'EmbedEntity',
    source: :entity

  after_create { notify_crawler(:start) }
  after_update { notify_crawler(:restart) }
  after_destroy { notify_crawler(:stop) }

  def blocking_filter
    self.filters.where(classification: 'blocking').first
  end

  def moderating_filter
    self.filters.where(classification: 'moderating').first
  end

  def valid_services
    services.all.select { |s| s.service_config.valid? }
  end

  def moderate
    self.entities
      .satisfying(moderating_filter)
      .each do |entity|
        entity.embed_entities
          .select { |ee| ee.embed == self }
          .each { |ee| ee.is_approved = true ; ee.save }
      end
  end

  def make_link_to(entity)
    self.embed_entities.create(entity: entity, is_approved: self.approved_by_default)
  end

  private 

  def notify_crawler(action)
    unless ENV['RAILS_ENV'] == 'test'
      Rails.logger.info "Publishing a command to crawler #{msg(action)}"
      x('x.crawler').publish((msg(action).to_json), routing_key: :config)
    end
  end

  def msg(action)
    {
      brand: {
        id: brand.id,
        name: brand.name
      },
      embed: {
        id: id,
        name: name
      },
      signature: "embed_#{action}",
      action: action
    }
  end
end
