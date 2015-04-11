class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  scope :approved, lambda { where(is_approved_manually: true) }
  scope :waitlisted, lambda { where(is_approved_manually: false) }

  def approve
    update_attribute(:is_approved_manually, true)
    entity.touch
  end

  def block
    update_attributes({is_approved_manually: false, is_pinned: false})
    entity.touch
  end
  alias_method :disapprove, :block

  def pin
    update_attributes({is_pinned: true, is_approved_manually: true})
    entity.touch
  end

  def unpin
    update_attribute(:is_pinned, false)
    entity.touch
  end

  def disconnect
    destroy
  end
end
