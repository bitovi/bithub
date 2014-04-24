require 'httparty'

class Configurator
  include Celluloid
  include CoreHelpers

  def initialize(opts)
    @env = opts.fetch(:environment)
    @all_brands = symbolize_keys remote_config
    Celluloid.logger.debug "All brands: #{@all_brands}"
  end
  attr_reader :all_brands

  def static_config
    path = File.expand_path(File.join('config', 'services', 'crawler', "#{@env}.yml"))
    @static_config ||= YAML.load_file path
  end

  def brand(brand_name)
    all_brands.fetch(brand_name.to_sym)
  end
  alias_method :brand_config, :brand

  def feed(brand_name, feed_name)
    all_brands.fetch(brand_name.to_sym).fetch(feed_name.to_sym)
  end
  alias_method :feed_config, :feed

  def whole_config
    all_brands.merge(static_config)
  end

  def reload
    @brands_config = remote_config
  end

  private

  def remote_config
    HTTParty.get url, :query => {:token => 'dedamrazcetidonjetdarove'}
  end

  def url
    @env == 'development' ? 'http://bithub.dev/api/v2/feed_configs/tree' : 'http://bithub.com/api/v2/feed_configs/tree'
  end

end
