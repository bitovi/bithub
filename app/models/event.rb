require 'digest/md5'

class Event < ActiveRecord::Base
  VALID_FEEDS_FOR_IDENT = %w(github twitter)
  class EventHasNoParentError < Error; end
  class DistinctFieldNotKnown < Error; end

  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :tag_list,
    :origin_date, :origin_ts, :thread_updated_at,
    :created_at, :updated_at,
    :props, :source_data, :image

  attr_accessor :meta

  acts_as_taggable_on :tags
  mount_uploader :image, EventImageUploader

  belongs_to :parent, :class_name => "Event"
  has_many :children, :foreign_key => "parent_id", :class_name => "Event"

  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"
  has_many :upvotes, :foreign_key => "applies_to_id"
  has_many :anteups, :foreign_key => "applies_to_id"
  has_many :awards, :foreign_key => "applies_to_id"

  validates :origin_date, :origin_ts, :hash_key, :feed_id, :category_id, :rule_id, :tag_list, :title, :presence => true
  validates :hash_key, :uniqueness => true

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :source_data, JSON

  scope :this_week, lambda { where(:origin_date => Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :last_week, lambda { where(:origin_date => 1.weeks.ago.to_date.beginning_of_week..1.week.ago.to_date.end_of_week) }
  scope :x_weeks_ago, lambda {|x| where(:origin_date => x.weeks.ago.to_date.beginning_of_week..x.weeks.ago.to_date.end_of_week) }

  def self.new_from_crawler(args = {}, meta)
    ev = self.new(args)
    ev.meta = meta.symbolize_keys
    ev.whole_chain
  end

  def self.new_from_bithub(args)
    event             = self.new
    event.hash_key    = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])
    event.origin_date = Date.today
    event.origin_ts   = DateTime.now
    event.image       = args[:image]
    event.determine_all(args)
    Event.clean_args_after_determination!(args)
    event.assign_attributes(args)
    event
  end

  def update_from_bithub(args)
    self.determine_all(args)
    Event.clean_args_after_determination!(args)
    self.assign_attributes(args)
    self.save
  end

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def initialize(args = {})
    args[:id] = Event.next_id
    super
  end

  def whole_chain
    pluck_props
    determine_all_from_meta
    process_forums
    process_github
    process_twitter
    bump_thread
    self
  end

  def pluck_props
    props[:origin_author_name] = meta[:origin_author_name] if meta[:origin_author_name]
    props[:origin_author_id] = meta[:origin_author_id] if meta[:origin_author_id]
    props[:image] = meta[:image] if meta[:image]
    props[:mongo_id] = meta[:mongo_id] if meta[:mongo_id]
  end

  def determine_all(args)
    self.tag_list    = Event.determine_tags(tags_from_args(args))
    self.feed        = Event.determine_feed(args[:feed])
    self.category    = Event.determine_category(args[:category])
    self.rule        = Event.determine_rule(self.tag_list)
    self.author      = Event.determine_author(args[:origin_author_feed], args[:origin_author_id])
    self
  end

  def determine_all_from_meta
    determine_tags_from_meta
    determine_feed_from_meta
    determine_category_from_meta
    determine_rule_from_meta
    determine_author_from_meta
    self
  end

  def self.determine_tags(tags)
    ActsAsTaggableOn::TagList.new(tags)
  end

  def self.determine_feed(feed_name)
    Tag.find_by_name(feed_name) || Tag.find_or_create_with_like_by_name(feed_name)
  end

  def self.determine_category(category_name)
    Tag.find_by_name(category_name) || Tag.find_or_create_with_like_by_name(category_name)
  end
  
  def self.determine_rule(tags)
    Rule.best_match(tags)
  end

  def self.determine_author(provider, uid)
    ident = Identity.find_or_create_with_provider_and_uid(provider, uid)
    ident.user
  end

  def determine_tags_from_meta
    tags = (meta[:tags] << meta[:feed] << meta[:type] << meta[:category]).reject {|el| el.nil?}
    self.tag_list = ActsAsTaggableOn::TagList.new(tags)
    self
  end

  def determine_feed_from_meta
    self.feed = Event.determine_feed(meta[:feed])
    self
  end

  def determine_category_from_meta
    self.category = Event.determine_category(meta[:category])
    self
  end

  def determine_rule_from_meta
    self.rule = Event.determine_rule(meta[:tags])
    self
  end

  def determine_author_from_meta
    props[:origin_author_id] = meta[:origin_author_id]
    props[:origin_author_username] = meta[:origin_author_username]
    ident = Identity.find_by_provider_and_uid(meta[:feed], meta[:origin_author_id])
    self.author = ident.user if ident && ident.user
    self
  end

  def process_forums
    group_forum_reply if tag_list.include?('forums')
    self
  end

  def process_github
    if tag_list.include?('github')

      # issues
      if tag_list.include?('issues_event')
        props[:issue_id] = meta[:issue_id]
        props[:state] = meta[:state]
        group_issue
      end

      # issue comments
      if tag_list.include?('issue_comment_event')
        props[:issue_id] = meta[:issue_id]
        group_issue_comment    
      end

      # push
      if tag_list.include?('push_event')
        props[:commits] = meta[:commits]
        group_push_event
      end

      # commit comments
      if tag_list.include?('commit_comment_event')
        props[:commit_id] = meta[:commit_id]
        group_commit_comment
      end

    end
    self
  end

  def process_twitter    
    if tag_list.include?('twitter') && tag_list.include?('status_event')

      props[:tweet_id] = meta[:tweet_id]
      if meta[:retweeted_id]
        props[:retweeted_id] = meta[:retweeted_id]
        group_retweet
      else
        group_tweet
      end
    end

    self
  end

  def siblings
    parent.children
  end

  def activities
    activities = []
    activities.concat(self.awards)
    activities.concat(self.upvotes)
    activities.concat(self.anteups)
  end

  def self.select_with_upvotes(include_events = true)
    query_string = "(SELECT COALESCE (SUM(u.value), 0) FROM upvotes AS u WHERE u.applies_to_id = events.id) as total_upvotes"
    query_string = "events.*, " + query_string if include_events
    select(query_string)
  end

  def self.only_parent_events
    where("parent_id IS NULL") # excludes events that have parent_id set
  end

  def awarded?
    self.awards.length > 0
  end

  def bump_thread
    now = Time.now
    if self.parent_id
      self.parent.update_attribute(:thread_updated_at, now)
      Event.where(:parent_id => self.parent_id).update_all(:thread_updated_at => now)
    else
      self.update_attribute(:thread_updated_at, now)
    end
  end

  def cache_key
    case
    when new_record?
      "#{self.class.model_name.cache_key}/new"
    when (event_updated = self[:updated_at]) && (thread_updated = self[:thread_updated_at])
      event_updated_utc = event_updated.utc.to_s(:number)
      thread_updated_utc = thread_updated.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{event_updated_utc}-#{thread_updated_utc}"
    when timestamp = self[:updated_at]
      timestamp = timestamp.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
    else
      "#{self.class.model_name.cache_key}/#{id}"
    end
  end

  private
  ### TWITTER methods
  def group_retweet
    if orig_tweet = Event.orig_tweet(props[:retweeted_id])
      self.parent = orig_tweet
    else
      self.parent = Event.other_retweet(props[:retweeted_id])
    end
    self
  end

  def group_tweet
    self.children += Event.collect_retweets_of(props[:tweet_id])
    self
  end

  ### FORUMS methods
  def adopt_children_for_forum_thread_starter
    thread_url, _ = url.split("#")
    self.children += Event.find_forum_thread_events_by_url(thread_url)
    self
  end

  def group_forum_reply
    thread_url, _ = url.split('#')
    replies = Event.find_forum_thread_events_by_url(thread_url).order('origin_ts ASC')

    if replies.length > 0
      if self.origin_ts > replies.first.origin_ts
        self.parent_id = replies.first.id
      else
        adopt_children_for_forum_thread_starter
      end
    end
    self
  end

  # GITHUB methods
  def adopt_children_for_github_issue
    self.children += Event.collect_issue_comments(props[:issue_id])
    self
  end

  def group_issue
    if issues_event = Event.find_issues_event_by_issue_id(props[:issue_id])
      self.parent = issues_event
    else
      adopt_children_for_github_issue
    end
    self
  end

  def group_push_event
    self.children += Event.collect_commit_comments(props[:commits])
    self
  end

  def group_issue_comment
    if issues_event = Event.parent_issues_event(props[:issue_id])
      self.parent = issues_event
    else
      self.parent = Event.sibling_issue_comment_event(props[:issue_id])
    end  
    self
  end

  def group_commit_comment
    if push_event = Event.parent_push_event(props[:commit_id])
      self.parent = push_event
    else
      self.parent = Event.sibling_commit_comment_event(props[:commit_id])
    end
    self
  end

  # Helper methods
  def self.has_an_attribute?(attr)
    Event.reflections.include?(attr.to_sym) ||
    Event.reflections.include?(attr.to_s.pluralize.to_sym) ||
    Event.attribute_names.include?(attr.to_s) ||
    Event.attribute_names.include?(attr.to_s.pluralize)
  end

  # Aliases, and explicitly named finders
  def self.find_tweet_by_tweet_id(tweet_id)
    Event.tagged_with(['twitter','status_event']).where("props -> 'tweet_id' = '#{tweet_id}'").first
  end

  def self.collect_retweets_of(tweet_id)
    Event.tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{tweet_id}'")
  end

  def self.find_forum_thread_events_by_url(thread_url)
    Event.tagged_with('forums').where("url LIKE '#{thread_url}%'")
  end

  def self.find_push_event_by_commit_id(commit_id)
    Event.tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
  end

  def self.find_issues_event_by_issue_id(issue_id)
    Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
  end

  def self.find_issue_comment_event_by_issue_id(issue_id)
    Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").first
  end

  def self.find_commit_comment_event_by_commit_id(commit_id)
    Event.tagged_with(['github','commit_comment_event']).where("props -> 'commit_id' = '#{commit_id}'").first
  end

  def self.collect_issue_comments(issue_id)
    Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").all
  end

  def self.collect_commit_comments(commits)
    Event.tagged_with(['github','commit_comment_event']).where("position(props -> 'commit_id' in '#{commits}') > 0").all
  end

  def self.parent_issues_event(issue_id)
    Event.find_issues_event_by_issue_id(issue_id)
  end

  def self.sibling_issue_comment_event(issue_id)
    Event.find_issue_comment_event_by_issue_id(issue_id)
  end

  def self.parent_push_event(commit_id)
    Event.find_push_event_by_commit_id(commit_id)
  end

  def self.sibling_commit_comment_event(commit_id)
    Event.find_commit_comment_event_by_commit_id(commit_id)
  end

  def self.orig_tweet(retweeted_id)
    Event.find_tweet_by_tweet_id(retweeted_id)
  end

  def self.other_retweet(retweeted_id)
    Event.find_tweet_by_tweet_id(retweeted_id)
  end

  def self.clean_args_after_determination!(args)
    args.delete(:category)
    args.delete(:feed)
    args.delete(:project)
    args.delete(:tags)
    args.delete(:origin_author_feed)
    args.delete(:origin_author_id)
    args
  end

  def tags_from_args(args)
    tags = []
    tags.push args[:category] if args[:category]
    tags.push args[:feed] if args[:feed]
    tags.push args[:project] if args[:project]
    tags.concat args[:tags] if args[:tags]
    tags
  end
end
