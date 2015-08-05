class Account < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :confirmable, :invitable

  rolify :role_cname => 'AccountRole'

  has_many :organizations, through: :account_organizations
  has_many :account_organizations, dependent: :destroy

  attr_accessor :current_password

  def brand_ids
    organizations.map do |o|
      o.brand_ids
    end.uniq.flatten
  end

  def brands
    organizations.map do |o|
      o.brands
    end.uniq.flatten
  end
end
