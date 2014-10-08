class Account < ActiveRecord::Base
  rolify :role_cname => 'AccountRole'

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  has_and_belongs_to_many :brands

end
