class Account < ActiveRecord::Base
  attr_accessor :invite_key

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :confirmable

  rolify :role_cname => 'AccountRole'

  validate :invite_key_must_match

  has_and_belongs_to_many :brands

  def current_brand
    brands.first
  end

  def invite_key_must_match
    if invite_key != ENV['INVITE_KEY']
      errors.add(:invite_key, "does not match")
    end
  end
end
