class Embed < ActiveRecord::Base
  belongs_to :brand
  validates_uniqueness_of :name, :scope => [:brand_id]

  has_many :filters, dependent: :destroy
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

  after_create :notify_embed_start
  after_update :notify_embed_restart
  after_destroy :notify_embed_stop

  def blocking_filter
    self.filters.where(classification: 'blocking').first
  end

  def moderating_filter
    self.filters.where(classification: 'moderating').first
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
    self.embed_entities.create(entity: entity, is_approved: true)
  end
  

  def notify_embed_start
    Support::CrawlerNotifier.new.notif({
      brand_name: brand.name,
      embed_name: name,
      action: :start
    })
  end
  
  def notify_embed_restart
    Support::CrawlerNotifier.new.notif({
      brand_name: brand.name,
      embed_name: name,
      action: :restart
    })
  end
  
  def notify_embed_stop
    Support::CrawlerNotifier.new.notif({
      brand_name: brand.name,
      embed_name: name,
      action: :stop
    })
  end
end
