require './lib/logger_factory'

Bithub::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Use a different cache store
  config.cache_store   = :redis_store, "#{ENV['REDIS_URL']}/cache", { expires_in: 7.days }

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Logging with log4r
  lf = LoggerFactory.new 'rails', :environment => Rails.env
  config.logger = lf.component_logger
  config.action_controller.logger = lf.ac_logger
  config.active_record.logger = lf.ar_logger
  config.log_level = :info

  # Don't care if the mailer can't send
  config.action_mailer.default_url_options = { host: "bithub.loc" }
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # :sql breaks migrations during deployment
  config.active_record.schema_format = :ruby

  config.eager_load = true
end
