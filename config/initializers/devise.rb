require 'devise/orm/active_record'
require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'
require 'omniauth-stackexchange'
require 'omniauth-facebook'
require 'omniauth-disqus'

Devise.setup do |config|
  config.secret_key = '2aa637d41eb2b387b2bb19211702de5bafd653317bc8df921ffa1279c6f73c81418e49aa1fea745a22f322439311b9cd4b92320a12cadab54a6069b4763272f5'

  config.omniauth :meetup,
    ENV['MEETUP_CLIENT_ID'],
    ENV['MEETUP_CLIENT_SECRET']

  config.omniauth :github,
    ENV['GITHUB_CLIENT_ID'],
    ENV['GITHUB_CLIENT_SECRET'],
    scope: "user:email,read:org"

  config.omniauth :twitter,
    ENV['TWITTER_CLIENT_ID'],
    ENV['TWITTER_CLIENT_SECRET']

  config.omniauth :stackexchange,
    ENV['STACKEXCHANGE_CLIENT_ID'],
    ENV['STACKEXCHANGE_CLIENT_SECRET'],
    public_key: ENV['STACKEXCHANGE_CLIENT_KEY'],
    site: 'stackoverflow'

  config.omniauth :disqus,
    ENV['DISQUS_CLIENT_ID'],
    ENV['DISQUS_CLIENT_SECRET']

  config.omniauth :facebook,
    ENV['FACEBOOK_CLIENT_ID'],
    ENV['FACEBOOK_CLIENT_SECRET'],
    :scope => 'email,manage_pages'

  config.omniauth :foursquare,
    ENV['FOURSQUARE_CLIENT_ID'],
    ENV['FOURSQUARE_CLIENT_SECRET']

  config.omniauth :instagram,
    ENV['INSTAGRAM_CLIENT_ID'],
    ENV['INSTAGRAM_CLIENT_SECRET']

  config.omniauth :tumblr,
    ENV['TUMBLR_CLIENT_ID'],
    ENV['TUMBLR_CLIENT_SECRET']

  config.sign_out_via = [:delete, :get]
end
