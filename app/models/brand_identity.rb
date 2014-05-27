class BrandIdentity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data, :brand

  belongs_to :brand
  serialize :source_data, JSON

  after_save :create_feed_config

  def create_feed_config
    if self.brand && self.provider
      feed_name = self.provider.gsub('_brand','')

      self.brand.feed_configs.create({
        feed_name: self.provider.gsub('_brand',''),
        config: {}
      }) unless self.brand.feed_configs.find_by_feed_name(feed_name)
    end
  end
end
