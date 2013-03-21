class Event < ActiveRecord::Base
  VALID_FEEDS_FOR_IDENT = %w(github twitter some_feed)
  class EventHasNoParentError < Error; end
  class DistinctFieldNotKnown < Error; end

  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :tags,
    :origin_date, :origin_ts,
    :props, :source_data

  attr_accessor :meta

  acts_as_taggable_on :tags

  belongs_to :parent, :foreign_key => "parent_id", :class_name => "Event", :autosave => true
  has_many :children, :foreign_key => "parent_id", :class_name => "Event", :autosave => true

  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"

  has_many :upvotes, :foreign_key => "applies_to_id", :autosave => true
  has_many :anteups, :foreign_key => "applies_to_id", :autosave => true
  has_many :awards, :foreign_key => "applies_to_id", :autosave => true

  validates :origin_date, :origin_ts, :hash_key, :feed, :category, :rule, :presence => true
  validates :hash_key, :uniqueness => true
  validates :tag_list, :presence => true

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :source_data, JSON

  scope :this_week, lambda { where(:origin_date => Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :last_week, lambda { where(:origin_date => 1.weeks.ago.to_date.beginning_of_week..1.week.ago.to_date.end_of_week) }
  scope :x_weeks_ago, lambda {|x| where(:origin_date => x.weeks.ago.to_date.beginning_of_week..x.weeks.ago.to_date.end_of_week) }

  after_validation {log_invalid.info "#{self.title}; #{self.meta}; #{self.errors.messages}" if self.invalid?}

  def log_invalid
    @@log_invalid ||= Logger.new("#{Rails.root}/log/invalid_events.log")
  end

  def self.new_with_checks(args ={}, meta)
    ev = self.new(args)
    ev.meta = meta.symbolize_keys
    ev.whole_chain
  end

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def initialize(args = {})
    args[:id] = Event.next_id
    super
  end

  def whole_chain
    determine_all
    process_forums
    process_github
    process_twitter
    self
  end

  def pluck_props
    # pluck attrs from source_data that we'll need later
  end

  def determine_all
    determine_tags
    determine_feed
    determine_category
    determine_rule
    determine_author
    self
  end


  def determine_tags
    meta[:tags] << meta[:feed] 
    meta[:tags] << meta[:type] if meta[:type]

    self.tag_list = meta[:tags].is_a?(Array) ? meta[:tags].join(',') : meta[:tags]
    self
  end

  def determine_feed
    self.feed = Tag.find_or_create_with_like_by_name(meta[:feed])
    self
  end

  def determine_category
    self.category = Tag.find_or_create_with_like_by_name(meta[:category])
    self
  end

  def determine_author
    props[:origin_author_id] = meta[:origin_author_id]
    props[:origin_author_username] = meta[:origin_author_username]
    ident = Identity.find_by_provider_and_uid(meta[:feed], meta[:origin_author_id])
    ident = Identity.create({provider: meta[:feed], uid: meta[:origin_author_id]}) if !ident && VALID_FEEDS_FOR_IDENT.include?(meta[:feed])
    self
  end

  def determine_rule
    self.rule = Rule.best_match(meta[:tags])
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

  def upvote(actor)
    Upvote.create_upvote(actor, self)
    self
  end

  def place_anteup(actor, value)
    Anteup.create_anteup(actor, self, value)
    self
  end

  def fullfill_anteups
    Anteup.fullfill_by_event(self)
    self
  end

  def award(actor)
    Award.create_award(actor, self)
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

  def self.nest_by(field)
    events = []
    if Event.reflect_on_all_associations.map{|x| x.name}.include? field.to_sym
      events = includes(field).all
    elsif Event.column_names.include?(field)
      events = all
    end
    remapped = Event.remap_field(field)
    ret_hash = {}
    events.map{|e| e[remapped] }.uniq.each do |dv|
      ret_hash[Event.name_for(field, dv)] = events.reject{|e| e[remapped] != dv}
    end
    ret_hash
  end

  
  private
    
  def self.remap_field(field)
    case field.to_sym
    when :category
      :category_id
    when :feed
      :feed_id
    else
      field
    end
  end

  def self.name_for(field, val)
    case field
    when :category
      Tag.find(val).name
    when :feed
      Tag.find(val).name
    else
      val
    end
  end

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

end
