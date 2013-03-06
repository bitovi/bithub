class Event < ActiveRecord::Base
  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :props, :tags,
    :origin_date, :origin_ts,
    :raw_json

  attr_accessor :props

  acts_as_taggable

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
    self.determine_tags.determine_feed.determine_category.determine_rule.group_if_forum_reply
    self
  end

  def determine_author
    self.author_id = User.find_or_create({:provider => props[:feed], :uid => props[:origin_author_id]})
    self
  end

  def determine_rule
    self.rule = Rule.best_match(props[:tags])
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
    self.tag_list = self.props[:tags].join(',')
    self
  end

  def adopt_children_for_forum_thread_starter
    thread_url = url.split("#")[0]

    Event.from_forums.where("url LIKE ?", thread_url).each do |event|
      self.children << event
    end
  end

  def group_if_forum_reply
    if tags.include?('forums')
      thread_url, thread_reply_nmb = url.split('#')
      if not thread_reply_nmb
        Rails.logger.info "STARTER!"
        adopt_children_for_forum_thread_starter
      elsif Event.from_forums.where(:url => thread_url).first
        Rails.logger.info "CHILD!"
        self.parent = Event.from_forums.where(:url => thread_url).first
      else
        Rails.logger.info  "SIBLING!"
        self.parent = Event.from_forums.where("url LIKE ?", thread_url).first
      end
    end
    self
  end



  def group_if_commit_comment
    if tagged_with(['github', 'commit_comment_event'])
      if existing_push_event = Event.from_github.pushes # + where 'source_data.payload.commit ...
        existing_push_event.add_to_thread(self)

        # Append the new commit comment to the existing comment
      elsif existing_commit_comment_event = Event.from_github.pushes # + where 'source_data.payload.comment.commit_id': self.getCommitId()
        existing_commit_comment_event.add_to_thread(self);
        existing_commit_comment_event.save
      end
    else
      return false
    end
  end

  def group_if_issue_or_issue_comment
    if tagged_with('github')
      if existing_issue = Event.from_github.issues # + where 'source_data.payload.issue.id': self.getIssueId()
        # The new event is an update (open/close) of an existing issue
        if tagged_with('issues_event')
          existing_issue.add_to_thread(self);
          existing_issue.state = self.state;

          # The new event is a comment on a existing issue
        elsif tagged_with('issue_comment_event')
          existing_issue.add_to_thread(self)
        end

      elsif existing_issue_comment = Event.from_github.issue_comments # + where 'source_data.payload.issue.id': self.getIssueId()
        # New event is an issue that already has comments in the system
        if tagged_with('issues_event')
          existing_issue_comment.add_to_thread(self)
          make_thread_starter

          # New event is a comment, and there is no issues_event to append it to
        elsif tagged_with('issue_comment_event')
          existing_issue_comment.add_to_thread(self)
        end
      end
    else
      return false
    end
  end

  def group_if_retweet
    if tagged_with(['twitter', 'status_event'])
      if tagged_with('retweet') && original_tweet = Event.tweets # + where 'source_data.id': self.source_data.retweeted_status.id'
        original_tweet.add_to_thread(self)
      elsif tagged_with('retweet') && another_retweet = Event.tweets # + where 'source_data.retweeted_status.id': self.source_data.retweeted_status.id'
        another_retweet.add_to_thread(self)
      elsif !tagged_with('retweet') && retweet_of_this_tweet = Event.tweets # + where 'source_data.retweeted_status.id' : self.source_id
        retweet_of_this_tweet.add_to_thread(self)
        self.make_thread_starter
      end
    else
      return false
    end
  end

  def siblings
    parent.children
  end

end
