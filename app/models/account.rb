class Account < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  # :token_authenticatable, :confirmable, :recoverable
  # :lockable, :timeoutable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :props

  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :brand
end
