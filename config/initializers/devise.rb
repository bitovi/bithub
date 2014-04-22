require 'devise/orm/active_record'
require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'
require 'omniauth-stackexchange'
require 'omniauth-facebook'
require 'omniauth-disqus'

Devise.setup do |config|
  config.secret_key = '2aa637d41eb2b387b2bb19211702de5bafd653317bc8df921ffa1279c6f73c81418e49aa1fea745a22f322439311b9cd4b92320a12cadab54a6069b4763272f5'

  # meetup
  config.omniauth :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']
  config.omniauth :meetup_brand, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']

  # github
  config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
  config.omniauth :github_brand, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email,read:org"

  # twitter
  config.omniauth :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  config.omniauth :twitter_brand, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']

  # stackexchange
  config.omniauth :stackexchange, ENV['STACKEXCHANGE_CLIENT_ID'], ENV['STACKEXCHANGE_CLIENT_SECRET'], public_key: ENV['STACKEXCHANGE_CLIENT_KEY'], site: 'stackoverflow'
  config.omniauth :stackexchange_brand, ENV['STACKEXCHANGE_CLIENT_ID'], ENV['STACKEXCHANGE_CLIENT_SECRET'], public_key: ENV['STACKEXCHANGE_CLIENT_KEY'], site: 'stackoverflow'

  # disqus
  config.omniauth :disqus, ENV['DISQUS_KEY'], ENV['DISQUS_SECRET']
  config.omniauth :disqus_brand, ENV['DISQUS_KEY'], ENV['DISQUS_SECRET']

  # facebook
  config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => 'email,read_stream'
  config.omniauth :facebook_brand, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => 'email,manage_pages'

  # foursquare
  config.omniauth :foursquare, ENV['FOURSQUARE_CLIENT_ID'], ENV['FOURSQUARE_SECRET']
  config.omniauth :foursquare_brand, ENV['FOURSQUARE_CLIENT_ID'], ENV['FOURSQUARE_SECRET']

  # yelp

  config.sign_out_via = [:delete, :get]
end
