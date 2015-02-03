class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  scope :approved, lambda { where(is_approved: true) }
  scope :waitlisted, lambda { where(is_approved: false) }
  
  def approve(account)
    if ModerationLog.new_entry(action: 'approved', caused_by: account.name)
      update_attribute(:is_approved, true)
    end
  end

  def disaprove(account)
    if ModerationLog.new_entry(action: 'disapproved', caused_by: account.name)
      update_attribute(:is_approved, false)
    end
  end

  def disconnect
    destroy
  end
end
