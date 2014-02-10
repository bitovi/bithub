class ApiCache < ActiveRecord::Base
  self.table_name = "api_cache"

  attr_accessible :name, :provider, :uid, :digest_type
  validates_presence_of :name, :provider, :uid
end
