Bithub::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Logging with log4r
  config.log_level = :info
  config.lograge.enabled = true
  config.active_record.logger = LoggerFactory.new('active_record', environment: 'test').logger
  config.action_controller.logger = LoggerFactory.new('action_controller', environment: 'test').logger
  config.logger = LoggerFactory.new('rails', environment: 'test').logger

  # Don't sent out actual 3rd party OAuth requests
  OmniAuth.config.test_mode = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "bithub.dev" }

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Drop schema to Ruby
  config.active_record.schema_format = :ruby

  config.eager_load = false
end
