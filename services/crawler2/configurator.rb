require 'active_record'

class FeedConfig < ActiveRecord::Base
  serialize :config, JSON
end

class Configurator
  include CoreHelpers

  DefaultEnv = 'development'
  def initialize(env)
    @env = env
    connect
  end
  attr_reader :config

  def static_config
    @config ||= YAML.load_file(File.expand_path(File.join('config', 'services', 'crawler', "#{@env}.yml")))
  end

  def whole_config
    all_brand_configs
  end

  def brand_config(brand_name)
    all_brand_configs.fetch(brand_name)
  end

  def feed_config(brand_name, feed_name)
    all_brand_configs.fetch(brand_name).fetch(feed_name)
  end

  private 

  # Converts relational result to a tree-like one
  def all_brand_configs
    # Dragons be here!
    @total ||= symbolize_keys(Hash[grouped.keys.zip(
      grouped.values.map do |bc|
        bc.each do |fc|
          fc.delete('brand_name')
        end.map do |fc|
          Hash[fc['feed_name'], fc['config']]
        end.reduce({}) do |acc, el|
          acc.merge(el)
        end
      end
    )])
  end

  def connect
    if (@conn_pool ||= ActiveRecord::Base.establish_connection(db_config))
      [:ok, nil]
    else
      [:error, "Could not connect"]
    end
  end

  def grouped
    @_grouped ||= FeedConfig.select(%i(brand_name feed_name config))
    .map(&:attributes)
    .group_by{|el| el['brand_name']}
  end

  def db_config
    @dbconfig ||= YAML.load_file(File.expand_path(File.join('config', 'database.yml')))
    @dbconfig.fetch(environment)
  end

  def environment
    @env || DefaultEnv
  end
end
