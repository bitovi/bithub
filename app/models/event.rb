class Event < ActiveRecord::Base
  VALID_FEEDS_FOR_IDENT = ['github', 'twitter', 'some_feed']
  class EventHasNoParentError < Error; end

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

  has_many :upvotes, :foreign_key => "applies_to_id", :autosave => true, :class_name => "Upvote"
  has_many :anteups, :foreign_key => "applies_to_id", :autosave => true, :class_name => "Anteup"
  has_many :awards, :foreign_key => "applies_to_id", :autosave => true, :class_name => "Award"

  has_many :activities, :finder_sql => proc { <<-SQL
    SELECT 
        'award' AS type,
        awards.value AS value,
        users.id AS user_id,
        users.name AS user_name,
        awards.updated_at AS ts
      FROM awards
        LEFT JOIN users ON users.id=awards.actor_id
        WHERE awards.applies_to_id=#{id}
    UNION
    SELECT 
        'anteup' AS type, 
        anteups.value AS value,
        users.id AS user_id,
        users.name AS user_name,
        anteups.updated_at AS ts
      FROM anteups 
        LEFT JOIN users ON users.id=anteups.actor_id
        WHERE anteups.applies_to_id=#{id}
    UNION
    SELECT 
        'upvote' AS type,
        value AS value,
        users.id AS user_id,
        users.name AS user_name,
        upvotes.updated_at AS ts
      FROM upvotes 
        LEFT JOIN users ON users.id=upvotes.actor_id
        WHERE upvotes.applies_to_id=#{id}
    ORDER BY ts DESC;
  SQL
  }

  validates :origin_date, :origin_ts, :hash_key, :feed, :category, :rule, :presence => true
  validates :hash_key, :uniqueness => true
  validates :tag_list, :presence => true

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :source_data, JSON

  def self.new_with_checks(args ={}, meta)
    ev = self.new(args)
    ev.meta = meta
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
    #puts "TAGS: #{tag_list}"
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

end
