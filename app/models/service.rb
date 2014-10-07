class Service < ActiveRecord::Base

  validates_presence_of :embed_id, :feed_name

  belongs_to :embed
  has_one :filter, as: :filterable, :dependent => :destroy

  def brand_identities
    self.brand.identities.where(:provider => feed_name).all
  end

  def brand
    self.embed.brand
  end

  def config
    ServiceConfig.new(json_config, feed_name)
  end

  def notify_crawler
    if service_config.valid?
      Support::CrawlerNotifier.new.notif({
        brand_name: brand.name,
        feed_name: feed_name,
        action: :restart
      })
    end
  end

end

# after_update :notify_crawler
# after_create :notify_crawler
