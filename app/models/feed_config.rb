class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :brand_name, :feed_name, :config

  serialize :config, JSON

  validates_presence_of :brand_name, :feed_name

  after_update :notify_crawler

  private

  def notify_crawler
    # current_tenant = Apartment::Database.current_tenant
    # return if current_tenant == Apartment::default_schema

    msg = {
      brand: self.brand_name,
      feed: self.feed_name,
      action: "reload"
    }

    AmqpHelpers.publish_to_mq \
      :msg => msg,
      :exchange_name => 'x.crawler',
      :exchange_type => 'fanout'
  end
end
