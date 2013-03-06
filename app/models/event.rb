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

  scope :chat, tagged_with('irc')
  scope :questions, tagged_with('question')
  scope :bugs, tagged_with('bug')
  scope :comments, tagged_with('comments')

  scope :from_twitter, tagged_with('twitter')
  scope :from_forums, tagged_with('forums')
  scope :from_github, tagged_with('github')
  scope :from_disqus, tagged_with('disqus')

  scope :pushes, tagged_with('push_event')
  scope :issues, tagged_with('issues_event')
  scope :issue_comments, tagged_with('issue_comment_event')
  scope :commit_comments, tagged_with('commit_comments')
  scope :tweets, tagged_with(['twitter', 'status_event'])

  serialize :props, ActiveRecord::Coders::Hstore

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def initialize(args = {})
    args[:id] = Event.next_id
    super
  end

  def cleanup(args)
    args.each do |k, v|
      if not Event.column_names.include? k.to_s
        args.delete k
      end
    end
  end

  def whole_chain
    self
      .determine_tags
      .determine_feed
      .determine_category
      .determine_rule
      .group_if_forum_reply

    self
  end

  def determine_author
    self.author_id = User.find_or_create({:provider => props[:feed], :uid => props[:origin_author_id]})
    self
  end

  def determine_rule
    self.rule = Rule.best_match(tags)
    self
  end

  def determine_feed
    self.feed = Tag.find_or_create(self.props[:feed], false, true)
    self
  end

  def determine_category
    self.category = Tag.find_or_create(self.props[:category], true, false)
    self
  end

  def determine_tags
    self.tag_list = self.props[:tags]
    self
  end

  def adopt_children_for_forum_thread_starter
    thread_url = url.split("#")[0]

    Event.from_forums.where("url LIKE ?", thread_url).each do |event|
      self.children << event
    end

    self
  end

  def group_if_forum_reply
    if tag_list.include?('forums')
      thread_url, thread_reply_nmb = url.split('#')

      if not thread_reply_nmb
        adopt_children_for_forum_thread_starter
      elsif Event.from_forums.where(:url => thread_url).first
        self.parent = Event.from_forums.where(:url => thread_url).first
      else
        self.parent = Event.from_forums.where("url LIKE ?", thread_url).first
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
    issue_id = props[:issue_id]

    Event.from_github.issue_comments.where("props -> 'issue_id' = '#{issue_id}'").each do |event|
      self.children << event
    end

    self
  end

  def group_if_issue_or_issue_comment
    if tags.include?('github') && props[:issue_id]
      issue_id = props[:issue_id]

      # check if issue or comment
      if tags.include?('issues_event')
        # update of existing event or a new one?
        if Event.from_github.issues.where("props -> 'issue_id' = '#{issue_id}'").first
          # WHAT TO DO? update existing or insert a new one into thread ? 
          self.parent = Event.from_github.issues.where("props -> 'issue_id' = '#{issue_id}'").first
        else
          adopt_children_for_github_issue
        end

      elsif tags.include?('issue_comment_event')
        # try to find issue or closest comment with same issue_id
        if Event.from_github.issues.where("props -> 'issue_id' = '#{issue_id}'").first
          self.parent = Event.from_github.issues.where("props -> 'issue_id' = '#{issue_id}'").first
        elsif
          self.parent = Event.from_github.issue_comments.where("props -> 'issue_id' = '#{issue_id}'").first
        end
      end
      
    end
    self
  end

  def group_if_retweet
    if tags.include?('twitter') && tags.include?('status_event')
      if tagged_with('retweet') && original_tweet = Event.tweets # + where 'source_data.id': self.source_data.retweeted_status.id'
        original_tweet.add_to_thread(self)
      elsif tagged_with('retweet') && another_retweet = Event.tweets # + where 'source_data.retweeted_status.id': self.source_data.retweeted_status.id'
        another_retweet.add_to_thread(self)
      elsif !tagged_with('retweet') && retweet_of_this_tweet = Event.tweets # + where 'source_data.retweeted_status.id' : self.source_id
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
