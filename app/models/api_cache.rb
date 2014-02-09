class ApiCache < ActiveRecord::Base
  set_table_name "api_cache"

  attr_accessible :name, :provider, :uid
  validates_presence_of :name, :provider, :uid
end
