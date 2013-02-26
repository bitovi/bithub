class User < ActiveRecord::Base
  attr_accessible :address, :city, :email, :name, :postal
end
