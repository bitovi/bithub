# Be sure to restart your server when you modify this file.
Bithub::Application.config.session_store \
  :redis_store,
  :redis_server => "#{ENV['REDIS_URL']}/session",
  :expire_after => 1.month,
  :domain => ".#{ENV['DOMAIN']}"
