require 'devise/orm/active_record'
require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'
require 'omniauth-stackexchange'
require 'omniauth-facebook'

Devise.setup do |config|
  config.secret_key = '2aa637d41eb2b387b2bb19211702de5bafd653317bc8df921ffa1279c6f73c81418e49aa1fea745a22f322439311b9cd4b92320a12cadab54a6069b4763272f5'

  config.omniauth :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']
  config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
  config.omniauth :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  config.omniauth :stackexchange, ENV['STACKEXCHANGE_CLIENT_ID'], ENV['STACKEXCHANGE_CLIENT_SECRET'], public_key: ENV['STACKEXCHANGE_KEY'], site: 'stackoverflow'
  config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']

  config.sign_out_via = :delete
end
