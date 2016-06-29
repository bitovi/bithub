require 'devise/orm/active_record'

require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-meetup'
require 'omniauth-stackexchange'
require 'omniauth-facebook'
require 'omniauth-disqus'
require 'omniauth-google-oauth2'

Devise.setup do |config|
  config.secret_key = '2aa637d41eb2b387b2bb19211702de5bafd653317bc8df921ffa1279c6f73c81418e49aa1fea745a22f322439311b9cd4b92320a12cadab54a6069b4763272f5'

  # OmniAuth
  config.omniauth_path_prefix = '/auth'

  config.omniauth :meetup,
    ENV.fetch('MEETUP_CLIENT_ID'),
    ENV.fetch('MEETUP_CLIENT_SECRET')

  config.omniauth :github,
    ENV.fetch('GITHUB_CLIENT_ID'),
    ENV.fetch('GITHUB_CLIENT_SECRET'),
    scope: "user:email,read:org"

  config.omniauth :twitter,
    ENV.fetch('TWITTER_CLIENT_ID'),
    ENV.fetch('TWITTER_CLIENT_SECRET')

  config.omniauth :stackexchange,
    ENV.fetch('STACKEXCHANGE_CLIENT_ID'),
    ENV.fetch('STACKEXCHANGE_CLIENT_SECRET'),
    public_key: ENV.fetch('STACKEXCHANGE_CLIENT_KEY'),
    site: 'stackoverflow'

  config.omniauth :disqus,
    ENV.fetch('DISQUS_CLIENT_ID'),
    ENV.fetch('DISQUS_CLIENT_SECRET')

  config.omniauth :facebook,
    ENV.fetch('FACEBOOK_CLIENT_ID'),
    ENV.fetch('FACEBOOK_CLIENT_SECRET'),
    :scope => 'email,manage_pages'

  config.omniauth :foursquare,
    ENV.fetch('FOURSQUARE_CLIENT_ID'),
    ENV.fetch('FOURSQUARE_CLIENT_SECRET')

  config.omniauth :instagram,
    ENV.fetch('INSTAGRAM_CLIENT_ID'),
    ENV.fetch('INSTAGRAM_CLIENT_SECRET'),
    scope: 'basic public_content'

  config.omniauth :tumblr,
    ENV.fetch('TUMBLR_CLIENT_ID'),
    ENV.fetch('TUMBLR_CLIENT_SECRET')

  config.omniauth :google_oauth2,
    ENV.fetch('GOOGLE_CLIENT_ID'),
    ENV.fetch('GOOGLE_CLIENT_SECRET'),
    prompt: 'select_account consent',
    scope: 'email, profile, https://www.googleapis.com/auth/youtube.readonly',
    access_type: 'offline'

  config.sign_out_via = [:delete, :get]

  # Mailer

  config.mailer_sender = '"BitHub" <no-reply@bithub.com>'
  Devise::Mailer.layout 'mailer'


  config.http_authenticatable_on_xhr = false
  config.navigational_formats = ["*/*", :html, :json]


  # config.case_insensitive_keys = [ :email ]
  # config.strip_whitespace_keys = [ :email ]

  # Http authenticatable

  # config.http_authenticatable = false
  # config.http_authenticatable_on_xhr = true
  
  # config.http_authentication_realm = 'Application'
  # config.paranoid = true

  config.skip_session_storage = [:http_auth]
  # config.clean_up_csrf_token_on_authentication = true

  # Database authenticatable

  config.stretches = Rails.env.test? ? 1 : 10
  # config.pepper = 'd24d63b39b2fa66d34fd6d2916110f8caae21c6ec502fe23254ff3abfc7a2e75cbbbbbdc67cb05c61361ae9913cecd1dd1bd014dc99683665eb47959c0860e83'

  # Confirmable

  config.reconfirmable = true
  config.allow_unconfirmed_access_for = 1.hour
  # config.confirm_within = 3.days

  # Rememberable

  # config.remember_for = 2.weeks
  # config.extend_remember_period = false
  # config.rememberable_options = {}

  # Validatable

  config.password_length = 8..128

  # Recoverable

  config.reset_password_keys = [ :email ]
  config.reset_password_within = 6.hours

end
