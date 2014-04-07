class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :feed_name, :config

  serialize :config, JSON

  after_update :notify_crawler

  private

  def notify_crawler
    current_tenant = Apartment::Database.current_tenant
    return if current_tenant == Apartment::default_schema

    msg = {
      brand: current_tenant,
      feed: self.feed_name,
      action: "reload"
    }

    AmqpHelpers::publish_to_mq \
      :msg => msg,
      :exchange_name => 'x.crawler',
      :exchange_type => 'fanout'
  end
end
