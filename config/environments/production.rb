Bithub::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Use a different cache store
  config.cache_store   = :redis_store, "#{ENV['REDIS_URL']}/cache", { expires_in: 7.days }

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  config.log_level = :info
  config.logger = Logger.new(STDOUT)

  # Mailgun as default mailer
  config.action_mailer.smtp_settings = {
    :address   => 'smtp.mailgun.org',
    :port      => 587,
    :enable_starttls_auto => true,
    :user_name => ENV['MAILGUN_USERNAME'],
    :password  => ENV['MAILGUN_API_KEY'],
    :authentication => 'login',
    :domain => 'out.bithub.com'
  }
  config.action_mailer.default_url_options = { host: ENV["EMBED_ENDPOINT"] }
  config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.eager_load = true
end
