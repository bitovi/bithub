class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  def is_approved
    read_attribute(:is_approved_manually).present? ? is_approved_manually? : is_approved_automatically?
  end

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
