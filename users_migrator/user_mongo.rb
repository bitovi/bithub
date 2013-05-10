class UserMongo
  include Mongoid::Document
  store_in collection: 'users'

  field :name
  field :email

  #field :email_hash
  field :joined_ts, type: DateTime
  #field :points

  field :providers # :twitter._json, :github._json

  field :address
  field :city
  field :postalCode
  field :stateProvince
  field :country

  field :upvotes, type: Array
end
