require 'httparty'

class Configurator
  include Celluloid
  include CoreHelpers

  def initialize(opts)
    @env = opts.fetch(:environment)
  end
  attr_reader :all_brands

  def whole_config
    reload unless @all_brands
    all_brands.merge(static_config)
  end
  
  def static_config
    @static_config ||= YAML.load_file config_file_path
    @static_config.fetch(:app_level)
  end

  def brand(brand_name)
    reload unless @all_brands
    all_brands.fetch(brand_name.to_sym)
  end
  alias_method :brand_config, :brand

  def feed(brand_name, feed_name)
    reload unless @all_brands
    all_brands.fetch(brand_name.to_sym).fetch(feed_name.to_sym)
  end
  alias_method :feed_config, :feed

  def reload
    @all_brands = symbolize_keys(remote_config)
  end

  def remote_config
    HTTParty.get url, :query => {:token => 'dedamrazcetidonjetdarove'}
  end

  def config_file_path
    File.expand_path(File.join('config', 'services', 'crawler', "#{@env}.yml"))
  end
  
  private
  def url
    ENV['CRAWLER_CONFIG']
  end

end
