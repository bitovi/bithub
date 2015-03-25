class Account < ActiveRecord::Base
  belongs_to :invite_code

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :confirmable

  rolify :role_cname => 'AccountRole'

  validate :account_with_valid_invite_code

  has_and_belongs_to_many :organizations #, through: :accounts_organizations

  def brand_ids
    organizations.reduce([]) do |a,o|
      a.push *o.brand_ids; a
    end
  end

  def code
    self.invite_code.andand.code || ""
  end

  def code=(code)
    self.invite_code = InviteCode.find_by_code(code.downcase)
  end

  def active_for_authentication?
    super && invite_code_valid?
  end

  def inactive_message
    invite_code_valid? ? super : :invite_code_invalid
  end

  def invite_code_valid?
    invite_code && (invite_code.has_remaining_uses? || invite_code.still_valid?)
  end

  def account_with_valid_invite_code
    if invite_code
      invite_code.run_validation
      if invite_code.errors.count > 0
        errors.add(:invite_code, "is not valid any more")
      end
    else
      errors.add(:invite_code, "is not valid")
    end
  end
end
