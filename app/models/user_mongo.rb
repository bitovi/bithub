class UserMongo
  include Mongoid::Document
  store_in collection: 'users'

  field :name
  field :email
  field :providers
  field :country
  field :city
  field :address
  field :postal
end
