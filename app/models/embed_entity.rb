class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  scope :approved, lambda { where(is_approved: true) }
  scope :waitlisted, lambda { where(is_approved: false) }
  
  def approve
    update_attribute(:is_approved, true)
  end

  def disaprove
    update_attribute(:is_approved, false)
  end

  def disconnect
    destroy
  end
end

