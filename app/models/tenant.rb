class Tenant < ActiveRecord::Base

  devise :rememberable, :trackable, :omniauthable

  attr_accessible :login,
    :name, :email,
    :address, :city, :postal, :state, :country,
    :remember_me

  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :country
end
