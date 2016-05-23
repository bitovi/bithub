require 'bits/disqus/post'
require 'bits/facebook/link'
require 'bits/facebook/photo'
require 'bits/facebook/status'
require 'bits/foursquare/checkin'
require 'bits/github/create'
require 'bits/github/delete'
require 'bits/github/fork'
require 'bits/github/issue_comment'
require 'bits/github/issue'
require 'bits/github/issue_action'
require 'bits/github/pull_request'
require 'bits/github/push'
require 'bits/github/watch'
require 'bits/instagram/media'
require 'bits/meetup/event'
require 'bits/meetup/rsvp'
require 'bits/rss/post'
require 'bits/stackexchange/answer'
require 'bits/stackexchange/comment'
require 'bits/stackexchange/question'
require 'bits/tumblr/photo'
require 'bits/tumblr/text'
require 'bits/tumblr/video'
require 'bits/twitter/follow'
require 'bits/twitter/tweet'
require 'bits/youtube/video'

require 'bits/feed_determinator'
require 'bits/type_determinator'

module Bits
  def self.bit_instance(event)
    bit_class(event).new(event)
  end

  def self.bit_class(event)
    FeedDeterminator.new(event).feed_module::TypeDeterminator.new(event).type_class
  end
end
