require 'devise/orm/active_record'
require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'

Devise.setup do |config|
  config.omniauth_path_prefix = '/api/auth'

  config.omniauth :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']
  config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
  config.omniauth :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  config.omniauth :stackexchange, ENV['STACKEXCHANGE_CLIENT_ID'], ENV['STACKEXCHANGE_CLIENT_SECRET'], public_key: ENV['STACKEXCHANGE_CLIENT_KEY'], site: 'stackoverflow'

  config.sign_out_via = :delete
end
