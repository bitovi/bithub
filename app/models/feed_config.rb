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

  def valid_config?
    send("valid_#{feed_name}?")
  end

  def valid_github?
    has?('token') && has?('orgs') && has?('repos')
  end

  def valid_facebook?
    has?('pages') && pages_have_token?
  end

  def valid_twitter?
    has?('token') && has?('token_secret') && has?('terms')
  end

  def valid_meetup?
    has?('token') && has?('groups') && has?('terms')
  end
  
  def valid_foursquare?
    has?('token') && has?('venues')
  end

  def has?(key)
    returning(config.has_key?(key) && config[key].present?) do |indeed|
      errors.add :config, "must have #{key}" unless indeed
    end
  end

  # TODO has_nested?

  private
  def returning(exp)
    yield exp
    exp
  end

  def pages_have_token?
    config.fetch('pages').has_key?('token')
  end

end
