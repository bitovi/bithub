class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include AmqpHelpers

  attr_accessible :brand_name, :feed_name, :config
  serialize :config, JSON
  validates_presence_of :brand_name, :feed_name
  after_update :notify_crawler
  after_create :notify_crawler
  before_save :clean_config
  before_save :set_keywords

  before_save :set_tokens

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

  def clean_config
    if is_facebook?
      if has?('pages')
        config['pages'] = config['pages'].map{|k,v| v}
      end
    end
  end

  def brand
    @_brand ||= Brand.find_by_name(brand_name)
  end

  def set_keywords
    if is_twitter?
      unless brand.nil?
        self.config ||= {}
        config['terms'] = brand.keywords || []
      end
    end
  end

  def set_tokens
    identity = brand.identities.where(provider: feed_name).first
    unless identity.nil?
      decorated = BrandIdentityDecorator.new(identity)
      config['access_token'] = decorated.data[:access_token]
      config['access_secret'] = decorated.data[:access_secret] if is_twitter?
    end
  end

  def is_github?
    feed_name == 'github'
  end

  def is_facebook?
    feed_name == 'facebook'
  end

  def is_twitter?
    feed_name == 'twitter'
  end

  def valid_github?
    has?('access_token') && has?('orgs') && has?('repos')
  end

  def valid_facebook?
    has?('pages') && pages_have_token?
  end

  def valid_twitter?
    has?('access_token') && has?('access_secret') && has?('terms')
  end

  def valid_meetup?
    has?('token') && has?('groups') && has?('terms')
  end

  def valid_foursquare?
    has?('token') && has?('venues')
  end

  def has?(key)
    returning(config && config.has_key?(key) && config[key].present?) do |indeed|
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
    config.fetch('pages').all?{|el| el.has_key?('access_token')}
  end

end
