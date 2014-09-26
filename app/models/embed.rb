class Embed < ActiveRecord::Base

  has_many :embed_filters, :dependent => :destroy
  has_many :filters, :through => :embed_filters

  has_many :embed_entities

  has_many :waitlisted_entities, -> { where :is_approved => false },
    :through => :embed_entities,
    :class_name => 'EmbedEntity',
    :source => :entity

  has_many :approved_entities, -> { where :is_approved => true },
    :through => :embed_entities,
    :class_name => 'EmbedEntity',
    :source => :entity

  def blocking_filter
    self.embed_filters.where(:classification => 'blocking').first.andand.filter
  end

  def moderating_filter
    self.embed_filters.where(:classification => 'moderating').first.andand.filter
  end

  def make_link_to(entity)
    self.entities << entity
  end
end

