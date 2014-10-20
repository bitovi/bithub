class Account < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  rolify :role_cname => 'AccountRole'

  has_and_belongs_to_many :brands

end
