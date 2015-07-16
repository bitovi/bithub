require 'events/disqus/post_event'
require 'events/facebook/photo_event'
require 'events/facebook/status_event'
require 'events/foursquare/checkin_event'
require 'events/github/commit_comment_event'
require 'events/github/create_event'
require 'events/github/custom_issue_event'
require 'events/github/delete_event'
require 'events/github/fork_event'
require 'events/github/github_event_accessors'
require 'events/github/issue_comment_event'
require 'events/github/issue_event'
require 'events/github/pull_request_event'
require 'events/github/pull_request_review_comment_event'
require 'events/github/push_event'
require 'events/github/reference'
require 'events/github/watch_event'
require 'events/instagram/media_event'
require 'events/meetup/event_event'
require 'events/meetup/rsvp_event'
require 'events/rss/post_event'
require 'events/stackexchange/answer_event'
require 'events/stackexchange/comment_event'
require 'events/stackexchange/question_event'
require 'events/tumblr/post_event'
require 'events/twitter/fake_follow_event'
require 'events/twitter/follow_event'
require 'events/twitter/tweet_event'

require 'events/feed_determinator'
require 'events/type_determinator'

module Events
  def self.event_instance(packet, hint = nil)
    event_class(packet, hint).new(packet[:source_data], packet[:meta])
  end

  def self.event_class(packet, hint = nil)
    FeedDeterminator.new(packet, hint).feed_module::TypeDeterminator.new(packet).type_class
  end
end
