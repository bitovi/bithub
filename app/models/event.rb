class Event < ActiveRecord::Base
  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :tags,
    :origin_date, :origin_ts,
    :props, :source_data

  attr_accessor :meta

  acts_as_taggable

  belongs_to :parent, :foreign_key => "parent_id", :class_name => "Event", :autosave => true
  has_many :children, :foreign_key => "parent_id", :class_name => "Event", :autosave => true

  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"

  has_many :activities, :foreign_key => "applies_to_id"

  validates :origin_date, :origin_ts, :hash_key, :feed, :category, :rule, :presence => true
  validates :hash_key, :uniqueness => true

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :source_data, JSON

  def self.new_with_checks(args ={})
    ev = self.new(args)
    ev.whole_chain
    self
  end

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def initialize(args = {})
    args[:id] = Event.next_id
    super
  end

  def whole_chain
    determine_tags
    determine_feed
    determine_category
    determine_rule
    determine_author
    process_forums
    process_github
    process_twitter
    self
  end

  def pluck_props
    # pluck attrs from source_data that we'll need later
  end

  def determine_tags
    self.tag_list = meta[:tags].is_a?(Array) ? meta[:tags].join(',') : meta[:tags]
    self
  end

  def determine_author
    ident = Identity.find_by_provider_and_uid(meta[:feed], meta[:origin_author_id])
    ident = Identity.create(meta[:feed], meta[:origin_author_id]) if !ident && ['twitter', 'github'].include? meta[:feed]
    ident.create_user unless ident.user
    self.author = ident.user
    self
  end

  def determine_rule
    self.rule = Rule.best_match(meta[:tags])
    self
  end

  def determine_feed
    self.feed = Tag.find_or_create(meta[:feed], false, true)
    self
  end

  def determine_category
    self.category = Tag.find_or_create(meta[:category], true, false)
    self
  end

  def process_forums
    if tag_list.include?('forums')
      self.group_if_forum_reply
    end
    self
  end

  def process_github
    if tag_list.include?('github')

      # issues
      if tag_list.include?('issues_event')
        props[:issue_id] = meta[:issue_id]
        group_if_issue
      end

      # issue comments
      if tag_list.include?('issue_comment_event')
        props[:issue_id] = meta[:issue_id]
        group_if_issue_comment    
      end

      # push
      if tag_list.include?('push_event')
        props[:commits] = meta[:commits]
        group_if_push
      end

      # commit comments
      if tag_list.include?('commit_comment_event')
        props[:commit_id] = meta[:commit_id]
        group_if_commit_comment
      end

    end
    self
  end

  def process_twitter    
    if tag_list.include?('twitter') && tag_list.include?('status_event')

      props[:tweet_id] = meta[:tweet_id]
      if meta[:retweeted_id]
        props[:retweeted_id] = meta[:retweeted_id]
        group_if_retweet
      else
        group_if_tweet
      end
    end

    self
  end


  ### TWITTER methods

  def group_if_retweet
    retweeted_id = props[:retweeted_id]

    orig_tweet = Event.tagged_with(['twitter','status_event']).where("props -> 'tweet_id' = '#{retweeted_id}'").first

    if orig_tweet
      self.parent = orig_tweet
    else
      parent = Event.tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{retweeted_id}'").first
    end
    self
  end

  def group_if_tweet
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

  def group_if_forum_reply
    thread_url, thread_reply_nmb = url.split('#')

    if not thread_reply_nmb
      adopt_children_for_forum_thread_starter
    elsif Event.tagged_with('forums').where(:url => thread_url).first
      self.parent = Event.tagged_with('forums').where(:url => thread_url).first
    else
      self.parent = Event.tagged_with('forums').where("url LIKE '#{thread_url}%'").first
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

  def group_if_issue
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

  def group_if_issue_comment
    issue_id = props[:issue_id]
    
    # try to find issue or closest comment with same issue_id
    if Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
      self.parent = Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
    elsif
      self.parent = Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").first
    end  
    self
  end

  def group_if_push
    commits = props[:commits]
    Event.tagged_with(['github','commit_comment_event']).where("position(props -> 'commit_id' in '#{commits}') > 0").each do |event|
      self.children << event
    end
    self
  end

  def group_if_commit_comment
    commit_id = props[:commit_id]

    # find push event containg wanted commit or closest commit comment
    if Event.tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
      self.parent = Event.tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
    else
      self.parent = Event.tagged_with(['github','commit_comment_event']).where("props -> 'commit_id' = '#{commit_id}'").first
    end
    
    self
  end


  def siblings
    parent.children
  end

end
