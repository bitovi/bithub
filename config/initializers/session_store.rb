# Be sure to restart your server when you modify this file.

# https://github.com/rails/rails/issues/2483
# Bithub::Application.config.session_store :redis_store, :expire_after => 1.month, domain: :all

Bithub::Application.config.session_store :cookie_store, :expire_after => 1.month, :domain => :all
