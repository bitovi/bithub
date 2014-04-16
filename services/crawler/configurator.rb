require 'strong_parameters'
require 'active_model'
require 'active_record'
require 'models/feed_config'

class Configurator
  include Celluloid
  include CoreHelpers

  def initialize(opts)
    @env = opts.fetch(:environment)
    connect
  end
  attr_reader :config

  def reload
    @grouped = fetch_grouped
  end

  def static_config
    path = File.expand_path(File.join('config', 'services', 'crawler', "#{@env}.yml"))
    @config ||= YAML.load_file path
  end

  def whole_config
    all_brand_configs
  end

  def brand_config(brand_name)
    all_brand_configs.fetch(brand_name.to_sym)
  end

  def feed_config(brand_name, feed_name)
    all_brand_configs.fetch(brand_name.to_sym).fetch(feed_name.to_sym)
  end

  private 

  # Converts relational result to a tree-like one, Dragons be here!
  def all_brand_configs
    symbolize_keys(Hash[grouped.keys.zip(
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
    @grouped ||= fetch_grouped
  end

  def fetch_grouped
    FeedConfig
    .select(%i(brand_name feed_name config))
    .all
    .select{|fc| fc.valid_config?}
    .map{|fc| fc.attributes}
    .group_by{|el| el['brand_name']}
  end

  def db_config
    @dbconfig ||= YAML.load_file(File.expand_path(File.join('config', 'database.yml')))
    @dbconfig.fetch(@env)
  end

  def app_auth
    {
      twitter: {
        api_key: 'huCmG0TZ7vs6leLqLNlGQ',
        api_secret: 'X4mx1qgGlZ1BVIFFUDB4kzrE1NV7t0nAjx5hY5tQOWQ'
      },
      meetup: {
        api_key: '663a24605a37767831495d6332546b4a'
      }
    }
  end
end
