# Force pre-load for later dynamic lookup with const_get.

require_relative 'builders/base'
require_relative 'builders/disqus'
require_relative 'builders/facebook'
require_relative 'builders/foursquare'
require_relative 'builders/github'
require_relative 'builders/meetup'
require_relative 'builders/stackexchange'
require_relative 'builders/twitter'

Identities::Builders::Github
Identities::Builders::Twitter
Identities::Builders::Disqus
Identities::Builders::Foursquare
Identities::Builders::Facebook
Identities::Builders::Meetup
Identities::Builders::Stackexchange
