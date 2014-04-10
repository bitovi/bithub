class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include AmqpHelpers

  attr_accessible :brand_name, :feed_name, :config
  serialize :config, JSON
  validates_presence_of :brand_name, :feed_name
  after_update :notify_crawler
  after_create :notify_crawler

  def notify_crawler
    msg = {
      brand_name: self.brand_name,
      feed_name: self.feed_name,
      action: :restart
    }

    Rails.logger.info "Publishing command #{msg}"
    rabbit(exchange_name: 'x.crawler').publish(msg, :config)
    [:ok, msg]
  end

  def terms
    if has_terms?
      config['terms']
    else
      no_terms
    end
  end

  def has_terms?
    not(config['terms'].nil?)
  end

  def no_terms
    [:error, "not a config with terms"]
  end

end
