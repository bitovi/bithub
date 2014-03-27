class BrandIdentity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data

  belongs_to :brand
  serialize :source_data, JSON

end
