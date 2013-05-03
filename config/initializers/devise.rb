require 'devise/orm/active_record'
require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'

Devise.setup do |config|
  config.omniauth_path_prefix = '/api/auth'

  config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
  config.omniauth :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  config.omniauth :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']

  config.sign_out_via = :delete
end
