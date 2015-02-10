class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  scope :approved, lambda { where(is_approved: true) }
  scope :waitlisted, lambda { where(is_approved: false) }
  
  def approve
    update_attribute(:is_approved, true)
  end

  def block
    update_attributes({is_approved: false, is_pinned: false})
  end
  alias_method :disapprove, :block
  
  def pin
    update_attributes({is_pinned: true, is_approved: true})
  end
  
  def unpin
    update_attribute(:is_pinned, false)
  end

  def disconnect
    destroy
  end
end
