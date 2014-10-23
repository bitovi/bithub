class Embed < ActiveRecord::Base

  belongs_to :brand

  has_many :filters, as: :filterable, dependent: :destroy

  has_many :services, dependent: :destroy

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

  def blocking_filter
    self.filters.where(classification: 'blocking').first
  end

  def moderating_filter
    self.filters.where(classification: 'moderating').first
  end

  def make_link_to(entity)
    self.embed_entities.create(entity: entity, is_approved: false)
  end
end

