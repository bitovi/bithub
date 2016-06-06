class UserOrganization < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  belongs_to :invited_by, class_name: "User", foreign_key: :invited_by_user_id

  scope :pending, lambda { where(invitation_accepted_at: nil) }
  scope :accepted, lambda { where.not(invitation_accepted_at: nil) }
  
  def confirm!
    update_attribute(:invitation_accepted_at, DateTime.now)
  end

  validates_uniqueness_of :user_id, :scope => [:organization_id]
end
