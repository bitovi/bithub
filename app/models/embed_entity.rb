class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  validates_uniqueness_of :embed_id, scope: [:entity_id]

  def is_approved
    (read_attribute(:is_approved_manually) != nil) ? is_approved_manually? : is_approved_automatically?
  end

  def approve
    returning(update_attribute(:is_approved_manually, true)) do
      entity.touch
    end
  end

  def block
    returning(update_attributes({is_approved_manually: false, is_pinned: false})) do
      entity.touch
    end
  end
  alias_method :disapprove, :block

  def pin
    returning(update_attributes({is_pinned: true, is_approved_manually: true})) do
      entity.touch
    end
  end

  def unpin
    returning(update_attribute(:is_pinned, false)) do
      entity.touch
    end
  end

  private
  def returning(exp)
    yield(exp)
    exp
  end
end
