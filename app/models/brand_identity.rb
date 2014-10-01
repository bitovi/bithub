class BrandIdentity < ActiveRecord::Base

  belongs_to :brand

  def config
    BrandIdentityConfig.new(source_data, provider_name)
  end
  alias_attribute :provider_name, :provider

  # TODO design is about INTENT, no domain code in after_hooks
  # def create_feed_config
  #   if self.brand && self.provider
  #     feed_name = self.provider.gsub('_brand','')

  #     self.brand.feed_configs.create({
  #       feed_name: self.provider.gsub('_brand',''),
  #       config: {}
  #     }) unless self.brand.feed_configs.find_by_feed_name(feed_name)
  #   end
  # end
end
