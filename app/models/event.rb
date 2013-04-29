require 'digest/md5'

class Event < ActiveRecord::Base
  VALID_FEEDS_FOR_IDENT = %w(github twitter)
  class EventHasNoParentError < Error; end
  class DistinctFieldNotKnown < Error; end

  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :tag_list,
    :origin_date, :origin_ts,
    :props, :source_data

  attr_accessor :meta

  acts_as_taggable_on :tags

  belongs_to :parent, :class_name => "Event"
  has_many :children, :foreign_key => "parent_id", :class_name => "Event"

  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"
  has_many :upvotes, :foreign_key => "applies_to_id"
  has_many :anteups, :foreign_key => "applies_to_id"
  has_many :awards, :foreign_key => "applies_to_id"

  validates :origin_date, :origin_ts, :hash_key, :feed, :category, :tag_list, :rule, :presence => true
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
    args.delete(:image) #TMP
    event = self.new
    event.tag_list    = [args[:category], args[:feed], args[:project]].join(',')
    event.feed        = Event.determine_feed(args[:feed])
    event.category    = Event.determine_category(args[:category])
    event.rule        = Event.determine_rule(event.tags)
    event.hash_key    = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])
    event.origin_date = Date.today
    event.origin_ts   = Time.now
    args.delete(:category)
    args.delete(:feed)
    args.delete(:project)
    event.assign_attributes(args)
    event
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
    determine_all
    process_forums
    process_github
    process_twitter
    self
  end

  def pluck_props
    props[:origin_author_name] = meta[:origin_author_name] if meta[:origin_author_name]
    props[:origin_author_id] = meta[:origin_author_id] if meta[:origin_author_id]
    props[:image] = meta[:image] if meta[:image]
  end

  def determine_all
    determine_tags_from_meta
    determine_feed_from_meta
    determine_category_from_meta
    determine_rule_from_meta
    determine_author
    self
  end


  def self.determine_feed(feed_name)
    Tag.find_or_create_with_like_by_name(feed_name)
  end

  def self.determine_category(category_name)
    Tag.find_or_create_with_like_by_name(category_name)
  end
  
  def self.determine_rule(tag_arr)
    Rule.best_match(tag_arr)
  end

  def determine_tags_from_meta
    tags = meta[:tags] << meta[:feed] << meta[:type] << meta[:category]
    self.tag_list = tags.join(',')
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

  def determine_author
    props[:origin_author_id] = meta[:origin_author_id]
    props[:origin_author_username] = meta[:origin_author_username]

    ident = Identity.find_by_provider_and_uid(meta[:feed], meta[:origin_author_id])
    if ident && ident.user
      self.author = ident.user
    elsif !ident && VALID_FEEDS_FOR_IDENT.include?(meta[:feed])
      ident = Identity.create({provider: meta[:feed], uid: meta[:origin_author_id]})
      ident.create_user({name: meta[:origin_author_username]})
      self.author = ident.user
    end
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

  def self.select_with_upvotes(with_events)
    query_string = "(SELECT COALESCE (SUM(u.value), 0) FROM upvotes AS u WHERE u.applies_to_id = events.id) as total_upvotes"
    if with_events
      query_string = "events.*, " + query_string
    end
    select(query_string)
  end

  private
  ### TWITTER methods
  def group_retweet
    retweeted_id = props[:retweeted_id]
    orig_tweet = Event.tagged_with(['twitter','status_event']).where("props -> 'tweet_id' = '#{retweeted_id}'").first
    if orig_tweet
      self.parent = orig_tweet
    else
      parent = Event.tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{retweeted_id}'").first
    end
    self
  end

  def group_tweet
    tweet_id = props[:tweet_id]
    Event.tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{tweet_id}'").each do |event|
      self.children << event
    end
    self
  end


  ### FORUMS methods
  def adopt_children_for_forum_thread_starter
    thread_url = url.split("#")[0]

    Event.tagged_with('forums').where("url LIKE '#{thread_url}%'").each do |event|
      self.children << event
    end

    self
  end

  def group_forum_reply
    thread_url = url.split('#')[0]
    replies = Event.tagged_with('forums').where("url LIKE '#{thread_url}%'").order('origin_ts ASC')

    if replies.length > 0
      if self.origin_ts > replies.first.origin_ts
        self.parent_id = replies.first.id
      else
        adopt_children_for_forum_thread_starter
      end
    end

    self
  end


  ### GITHUB methods
  def adopt_children_for_github_issue
    issue_id = props[:issue_id]
    Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").each do |event|
      self.children << event
    end
    self
  end

  def group_issue
    issue_id = props[:issue_id]
    # update of existing event or a new one?
    if Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
      # WHAT TO DO? update existing or insert a new one into thread ? 
      self.parent = Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
    else
      adopt_children_for_github_issue
    end
    self
  end

  def group_issue_comment
    issue_id = props[:issue_id]
    # try to find issue or closest comment with same issue_id
    if Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
      self.parent = Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
    elsif
      self.parent = Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").first
    end  
    self
  end

  def group_push_event
    commits = props[:commits]
    Event.tagged_with(['github','commit_comment_event']).where("position(props -> 'commit_id' in '#{commits}') > 0").each do |event|
      self.children << event
    end
    self
  end

  def group_commit_comment
    commit_id = props[:commit_id]
    # find push event containg wanted commit or closest commit comment
    if Event.tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
      self.parent = Event.tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
    else
      self.parent = Event.tagged_with(['github','commit_comment_event']).where("props -> 'commit_id' = '#{commit_id}'").first
    end
    self
  end

  def self.has_an_attribute?(attr)
    Event.reflections.include?(attr) ||
    Event.reflections.include?(attr.to_s.pluralize.to_sym) ||
    Event.attribute_names.include?(attr) ||
    Event.attribute_names.include?(attr.to_s.pluralize.to_sym)
  end
end
