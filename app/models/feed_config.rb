class FeedConfig < ActiveRecord::Base
  include AmqpHelpers

  belongs_to :brand

  validates_presence_of :feed_name
  validates_uniqueness_of :feed_name, scope: :brand_id

  after_update :notify_crawler
  after_create :notify_crawler

  Feeds = %i(facebook twitter github meetup foursquare stackexchange disqus rss irc)
  Feeds.each do |feed|
    define_method("is_#{feed}?") do
      feed_name == feed.to_s
    end
  end

  def notify_crawler
    if valid_config?
      msg = {
        brand_name: brand.name,
        feed_name: feed_name,
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
      [:error, "not a config with terms"]
    end
  end

  def has_terms?
    not(config['terms'].nil?)
  end

  def valid_config?
    send("valid_#{feed_name}?")
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
    has?('sites')
  end

  def valid_irc?
    has?('server') && has?('channels')
  end

  def valid_disqus?
    has?('forums')
  end

  def valid_stackexchange?
    has?('tags')
  end

  def has?(key)
    returning(config\
              && config.instance_of?(Hash)\
              && config.has_key?(key)\
              && config[key].present?) do |indeed|
      errors.add :config, "must have #{key}" unless indeed
    end
  end

  def pages_have_token?
    config.fetch('pages').all?{|el| el.has_key?('access_token')}
  end

  def presenter
    @presenter ||= Presenters::FeedConfigPresenter.new(self)
  end
  alias_method :builder, :presenter

  private

  def returning(exp)
    yield exp
    exp
  end

end
