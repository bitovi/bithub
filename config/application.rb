require File.expand_path('../boot', __FILE__)

require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/rollingfileoutputter'
include Log4r

require 'rails/all'

if defined?(Bundler)
  Bundler.setup
end

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

    # Log4r config
    # ------------
    config_data = YAML.load_file(File.join(Rails.root, 'config', 'log4r.yml'))
    log_cfg = YamlConfigurator
    log_cfg["ENV"] = Rails.env 
    log_cfg["MACHINE_NAME"] = ENV["MACHINE_NAME"].nil? ? `hostname`.to_s.gsub(/\n$/, "") : ENV["MACHINE_NAME"] 
    log_cfg["COMPONENT_NAME"] = 'service'
    log_cfg.decode_yaml( config_data['log4r_config'] )

    config.log_level = :unknown # Disable default Rails logger

    config.logger = Log4r::Logger['rails']
    config.active_record.logger = Log4r::Logger['active_record']
    config.action_controller.logger = Log4r::Logger['action_controller']
  end
end
