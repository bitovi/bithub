class BrandIdentity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data, :brand

  belongs_to :brand
  serialize :source_data, JSON

  after_save :create_feed_config

  def create_feed_config
    if self.brand && self.provider
      FeedConfig.create({
        brand_name: self.brand.name,
        feed_name: self.provider.gsub('_brand',''),
        config: {}
      })
    end
  end
end
