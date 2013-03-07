class Event < ActiveRecord::Base
  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :props, :tags,
    :origin_date, :origin_ts,
    :raw_json

  attr_accessor :props

  #acts_as_taggable
  acts_as_taggable_on :tags

  belongs_to :parent, :foreign_key => "parent_id", :class_name => "Event"
  has_many :children, :foreign_key => "parent_id", :class_name => "Event"

  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"

  has_many :activities, :foreign_key => "applies_to_id"

  validates :origin_date, :origin_ts, :hash_key, :feed, :category, :rule, :presence => true
  validates :hash_key, :uniqueness => true

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :raw_json, JSON

  def self.new_with_checks(args ={})
    ev = self.new(args)
    ev.whole_chain
    self
  end

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def initialize(args = {})
    args[:raw_json] = args.clone # deep copy of args so we can serialize without self-refs
    args[:id] = Event.next_id
    super
  end

  def whole_chain
    determine_tags
    determine_feed
    determine_category
    determine_rule
    group_if_forum_reply
    group_if_issue_or_issue_comment
    self
  end

  def pluck_props
    # pluck attrs from raw_json that we'll need later
  end

  def determine_tags
    self.tag_list = raw_json[:tags].is_a?(Array) ? raw_json[:tags].join(',') : raw_json[:tags]
    self
  end

  def determine_author
    self.author = Identity.find_by_provider_and_uid(raw_json[:feed], raw_json[:origin_author_id]).user
    self
  end

  def determine_rule
    self.rule = Rule.best_match(self.tags)
    self
  end

  def determine_feed
    self.feed = Tag.find_or_create(self.raw_json[:feed], false, true)
    self
  end

  def determine_category
    self.category = Tag.find_or_create(self.raw_json[:category], true, false)
    self
  end

  def adopt_children_for_forum_thread_starter
    thread_url = url.split("#")[0]
    Event.tagged_with('forums').where("url LIKE '#{thread_url}%'").each do |event|
      self.children << event
    end
    self
  end

  def group_if_forum_reply
    if tag_list.include?('forums')
      thread_url, thread_reply_nmb = url.split('#')
      if not thread_reply_nmb
        adopt_children_for_forum_thread_starter
      elsif Event.tagged_with('forums').where(:url => thread_url).first
        self.parent = Event.tagged_with('forums').where(:url => thread_url).first
      else
        self.parent = Event.tagged_with('forums').where("url LIKE '#{thread_url}%'").first
      end
    end
    self
  end

  def group_if_commit_comment
    if tags.include?('github') && tags.include?('commit_comment_event')
      commit_id = props['commit_id']
      # find push event containg wanted commit or closest commit comment
      if Event.from_github.pushes.where("props -> 'commits' LIKE #{commit_id}").first
        self.parent = Event.from_github.pushes.where("props -> 'commits' LIKE #{commit_id}").first
      else
        self.parent = Event.from_github.commit_comments.where("props -> 'commit_id' = #{commit_id}").first
      end
    end
    self
  end

  def adopt_children_for_github_issue
    issue_id = raw_json[:issue_id]
    Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").each do |event|
      self.children << event
    end
    self
  end

  def group_if_issue_or_issue_comment
    if tag_list.include?('github') && raw_json[:issue_id]
      issue_id = raw_json[:issue_id]
      # check if issue or comment
      if tag_list.include?('issues_event')
        # update of existing event or a new one?
        if Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
          # WHAT TO DO? update existing or insert a new one into thread ? 
          self.parent = Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
        else
          adopt_children_for_github_issue
        end
      elsif tag_list.include?('issue_comment_event')
        # try to find issue or closest comment with same issue_id
        if Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
          self.parent = Event.tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
        elsif
          self.parent = Event.tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").first
        end
      end

    end
    self
  end

  def group_if_retweet
    if tags.include?('twitter') && tags.include?('status_event')
      if tags.include?('retweet') && original_tweet = Event.tweets # + where 'source_data.id': self.source_data.retweeted_status.id'
        original_tweet.add_to_thread(self)
      elsif tags.include?('retweet') && another_retweet = Event.tweets # + where 'source_data.retweeted_status.id': self.source_data.retweeted_status.id'
        another_retweet.add_to_thread(self)
      elsif !tags.include?('retweet') && retweet_of_this_tweet = Event.tweets # + where 'source_data.retweeted_status.id' : self.source_id
        retweet_of_this_tweet.add_to_thread(self)
        self.make_thread_starter
      end
    end
    self
  end

  def siblings
    parent.children
  end

end
