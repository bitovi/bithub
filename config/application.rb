require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
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
    config.active_record.auto_explain_threshold_in_seconds = 0.5

    # Autoload 'lib' and 'domain' folders
    config.autoload_paths += %W(#{Rails.root}/app/domain #{Rails.root}/lib)

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # The query parsing middleware
    config.middleware.use Muster::Rack, Muster::Strategies::ActiveRecord
  end
end
