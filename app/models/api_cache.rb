class ApiCache < ActiveRecord::Base
  self.table_name = "api_cache"

  validates_presence_of :name, :provider, :uid
end
