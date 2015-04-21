class Account < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :confirmable

  rolify :role_cname => 'AccountRole'

  has_many :organizations, through: :accounts_organizations
  has_many :accounts_organizations, dependent: :destroy

  def brand_ids
    organizations.reduce([]) do |a,o|
      a.push *o.brand_ids; a
    end
  end
end
