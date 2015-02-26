require './lib/logger_factory'

Bithub::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Logging with log4r
  lf = LoggerFactory.new 'rails', :environment => Rails.env
  config.logger = lf.component_logger
  config.action_controller.logger = lf.ac_logger
  config.active_record.logger = lf.ar_logger
  config.log_level = :debug

  # Mandrill as default mailer
  config.action_mailer.smtp_settings = {
    :address   => "smtp.mandrillapp.com",
    :port      => 587,
    :enable_starttls_auto => true,
    :user_name => ENV['MANDRILL_USERNAME'],
    :password  => ENV['MANDRILL_API_KEY'],
    :authentication => 'login',
    :domain => 'bithub.loc'
  }
  config.action_mailer.default_url_options = { host: "bithub.loc" }
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Drop schema to Ruby
  config.active_record.schema_format = :ruby

  config.eager_load = false
  config.stripe.eager_load = ['brand', 'subscription', 'payment', 'stripe_webhooks_log']
end
