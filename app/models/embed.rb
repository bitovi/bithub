class Embed < ActiveRecord::Base
  include Traits::AmqpDeclaration

  belongs_to :brand
  validates_uniqueness_of :name, :scope => [:brand_id]

  has_many :filters, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :presets, :class_name => "EmbedPreset"

  has_many :embed_entities
  has_many :entities, through: :embed_entities

  has_many :events

  after_create { notify_crawler(:start) }
  after_update { notify_crawler(:restart) }
  after_destroy { notify_crawler(:stop) }

  def approved_entities
    if approving?
      embed_entities.where('embed_entities.is_approved IS NULL OR embed_entities.is_approved = TRUE').map(&:entity)
    elsif blocking?
      embed_entities.where('embed_entities.is_approved = TRUE').map(&:entity)
    end
  end

  def blocked_entities
    if approving?
      embed_entities.where('embed_entities.is_approved = FALSE').map(&:entity)
    elsif blocking?
      embed_entities.where('embed_entities.is_approved IS NULL OR embed_entities.is_approved = FALSE').map(&:entity)
    end
  end

  def approving?
    approved_by_default
  end

  def blocking?
    !approved_by_default
  end

  def blocking_filter
    self.filters.where(classification: 'blocking').first
  end

  def approving_filter
    self.filters.where(classification: 'approving').first
  end

  def valid_services
    services.all.select { |s| s.service_config.valid? }
  end

  def block_invalid
    entity_ids = entities.satisfying(blocking_filter).pluck(:id)
    EmbedEntity.where({embed_id: self.id, entity_id: entity_ids}).update_all(is_approved: false, is_pinned: false)
  end

  def approve_valid
    entity_ids = entities.satisfying(approving_filter).pluck(:id)
    EmbedEntity.where({embed_id: self.id, entity_id: entity_ids}).update_all(is_approved: true)
  end

  def make_link_to(entity, is_approved = nil)
    embed_entities.create(entity: entity, is_approved: is_approved)
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
