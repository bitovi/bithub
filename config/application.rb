require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sass/plugin/rack'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
  Bundler.setup
end

module Bithub
  class Application < Rails::Application

    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.schema_format = :sql
    config.i18n.enforce_available_locales = false

    # Autoload 'lib' and 'domain' folders
    config.autoload_paths += %W(#{Rails.root}/app #{Rails.root}/lib #{Rails.root}/services)

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # The query parsing middleware
    config.middleware.use Muster::Rack, Muster::Strategies::ActiveRecord

    # Stripe
    config.stripe.publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
    config.stripe.auto_mount = false

    config.middleware.use Sass::Plugin::Rack

    # possibly resolved issues with sidekiq :/
    Celluloid::LINKING_TIMEOUT = 10
  end
end
