require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  Bundler.setup
end

require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/datefileoutputter'

module Bithub
  class Application < Rails::Application

    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = true
    config.active_record.schema_format = :sql
    config.i18n.enforce_available_locales = false

    # Autoload 'lib' and 'domain' folders
    config.autoload_paths += %W(#{Rails.root}/app/domain #{Rails.root}/lib)

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # The query parsing middleware
    config.middleware.use Muster::Rack, Muster::Strategies::ActiveRecord

    # Logger config data
    if Rails.env.development?
      logger_config_data = YAML.load_file(File.join(Rails.root, 'config', 'log4r_dev.yml'))
    else
      logger_config_data = YAML.load_file(File.join(Rails.root, 'config', 'log4r.yml'))
    end

    log_cfg = Log4r::YamlConfigurator
    log_cfg["ENV"] = ENV['ENV']
    log_cfg["COMPONENT_NAME"] = "rails"
    log_cfg.decode_yaml(logger_config_data['log4r_config'])

    # Loggers
    config.logger = Log4r::Logger['component']
    config.action_controller.logger = Log4r::Logger['action_controller']
    config.active_record.logger = Log4r::Logger['active_record']
    
    config.log_level = :unknown
  end
end
