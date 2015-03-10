class InviteCode < ActiveRecord::Base
  has_many :invited_accounts, class: 'Account', foreign_key: :invite_code_id

  validates_presence_of :code
  validates_uniqueness_of :code

  validate :has_either_remaining_uses_or_valid_until,
    :remaining_uses_gt_0, :valid_until_gt_now


  def code=(code)
    write_attribute(:code, code.downcase)
  end

  def has_remaining_uses?
    remaining_uses > 1
  end

  def still_valid?
    Time.now < (valid_until || 1.year.from_now)
  end
  
  def use_up_if_useable
    if remaining_uses
      update_attribute(:remaining_uses, remaining_uses.pred)
    end
  end

  def run_validation
    has_either_remaining_uses_or_valid_until
    remaining_uses_gt_0
    valid_until_gt_now
  end

  def has_either_remaining_uses_or_valid_until
    if remaining_uses.nil? && valid_until.nil?
      errors.add(:remaining_uses, 'either remaining_uses or valid_until must be present')
      errors.add(:valid_until, 'either remaining_uses or valid_until must be present')
    end
  end

  def remaining_uses_gt_0
    if remaining_uses && !has_remaining_uses?
      errors.add(:remaining_uses, "has no more remaining uses")
    end
  end

  def valid_until_gt_now
    if valid_until && !still_valid?
      errors.add(:still_valid, "is not valid anymore")
    end
  end
end
