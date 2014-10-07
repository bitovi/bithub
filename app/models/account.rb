class Account < ActiveRecord::Base
  rolify :role_cname => 'AccountRole'

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  belongs_to :brand
end
