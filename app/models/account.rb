class Account < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :confirmable

  rolify :role_cname => 'AccountRole'

  has_many :organizations, through: :accounts_organizations
  has_many :accounts_organizations, dependent: :destroy

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
