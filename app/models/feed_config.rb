module ConfigBuilders

  class Generic

    attr_reader :feed_config, :brand_identity

    def initialize(feed_config, brand_identity)
      @feed_config    = feed_config
      @brand_identity = ::BrandIdentityDecorator.new(brand_identity)
    end

    def terms
      terms = ([] << brand_identity.brand.name)
      terms += (brand_identity.brand.keywords || []) & (feed_config.config.andand['terms'] || feed_config.config.andand['tags'] || [])
      terms.uniq
    end

    def config
      {}
    end

    def is_valid?
      feed_config.valid_config?
    end

  end

  class Github < Generic
    def config
      {
        access_token: brand_identity.andand.data[:access_token],
        repos: feed_config.andand.config['repos'] || [],
        orgs: feed_config.andand.config['orgs'] || []
      }
    end
  end

  class Twitter < Generic
    def config
      {
        access_token: brand_identity.andand.data[:access_token],
        access_secret: brand_identity.andand.data[:access_secret],
        terms: terms || []
      }
    end
  end

  class Facebook < Generic
    def config
      {
        token: brand_identity.andand.data[:access_token],
        pages: feed_config.andand.config['pages'] || []
      }
    end
  end

  class Stackexchange < Generic
    def config
      {
        token: brand_identity.andand.data[:access_token],
        terms: terms || []
      }
    end
  end

  class Disqus < Generic
    def config
      forums = feed_config.andand.config['forums'] || []
      {
        token: brand_identity.andand.data[:access_token],
        forums: forums.map{|p| p['id']} || []
      }
    end
  end

  class Meetup < Generic
    def config
      groups = feed_config.andand.config['groups'] || []
      {
        token: brand_identity.andand.data[:access_token],
        groups: groups.map{|g| g['id']} || [],
        terms: terms || []
      }
    end
  end

  class Rs < Generic
    def config
      { urls: feed_config.andand.config['urls'] || [] }
    end
  end

  class Foursquare < Generic
    def config
      venues = feed_config.andand.config['venues'] || []
      {
        venues: venues.map {|v| {id: v['id']}}
      }
    end
  end

end

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
    "ConfigBuilders::#{feed_name.classify}".constantize.new(self, brand.identities.where(provider: feed_name).first)
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
