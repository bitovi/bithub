require 'httparty'

class Configurator
  include Celluloid
  include CoreHelpers

  def initialize(opts)
    @env = opts.fetch(:environment)
    reload
    Celluloid.logger.debug "All brands: #{@all_brands}"
  end
  attr_reader :all_brands

  def static_config
    @static_config ||= YAML.load_file config_file_path
    @static_config.fetch(:app_level)
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
    @all_brands = symbolize_keys(remote_config)
  end

  private

  def remote_config
    HTTParty.get url, :query => {:token => 'dedamrazcetidonjetdarove'}
  end

  def url
    ENV['CRAWLER_CONFIG']
  end

  def config_file_path
    File.expand_path(File.join('config', 'services', 'crawler', "#{@env}.yml"))
  end

end
