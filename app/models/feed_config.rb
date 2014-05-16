class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include AmqpHelpers

  attr_accessible :brand_name, :feed_name, :config
  serialize :config, JSON
  validates_presence_of :brand_name, :feed_name
  after_update :notify_crawler
  after_create :notify_crawler
  before_save :clean_config

  def notify_crawler
    if valid_config?
      msg = {
        brand_name: self.brand_name,
        feed_name: self.feed_name,
        action: :restart
      }

      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.crawler').publish(msg, :config)
      [:ok, msg]
    end
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
    if is_meetup?
      if has?('groups')
        config['groups'] = config['groups'].map{|k,v| v}
      end
    end
    if is_disqus?
      if has?('forums')
        config['forums'] = config['forums'].map{|k,v| v}
      end
    end
  end

  def brand
    @_brand ||= Brand.find_by_name(brand_name)
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

  def is_disqus?
    feed_name == 'disqus'
  end

  def is_meetup?
    feed_name == 'meetup'
  end

  def valid_github?
    has?('orgs') || has?('repos')
  end

  def valid_facebook?
    has?('pages') && pages_have_token?
  end

  def valid_twitter?
    has?('terms')
  end

  def valid_meetup?
    has?('groups') || has?('terms')
  end

  def valid_foursquare?
    has?('venues')
  end

  def valid_rss?
    has?('urls')
  end

  def valid_disqus?
    has?('forums')
  end

  def valid_stackexchange?
    has?('tags')
  end

  def has?(key)
    returning(config && config.has_key?(key) && config[key].present?) do |indeed|
      errors.add :config, "must have #{key}" unless indeed
    end
  end

  def builder
    "ConfigBuilders::#{feed_name.capitalize}".constantize.new(self, brand.identities.where(provider: feed_name).first)
  end

  # TODO has_nested?

  private

  def returning(exp)
    yield exp
    exp
  end

  def pages_have_token?
    config.fetch('pages').all?{|el| el.has_key?('access_token')}
    true
  end

end
