class Event < ActiveRecord::Base
  attr_accessible :body, :hash_key, :title, :url
  
  acts_as_taggable
  
  belongs_to :rule
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"
  has_many :activities, :foreign_key => "applies_to_id"

  validates :date, :presence => true

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

  def determine_rule
  end

  def group_if_forum_reply
    if tagged_with('forums')
      new_event_split_url = url.split('#')[0]
      new_event_thread_url = new_event_split_url[0]
      new_event_thread_reply_nmb = split_url[1] if new_event_split_url[1] 
      
      if existing_forum_post = Event.from_forums.where("url LIKE ?", new_event_thread_url, hash_key).first
        existing_event_split_url = existing_forum_post.url.split('#')
        existing_event_thread_url = existing_event_split_url[0]
        existing_event_thread_reply_nmb = existing_event_split_url[1] if existing_event_split_url[1]

        # Existing event is a thread starter, new event is a reply, or both are replies
        if !existing_event_thread_reply_nmb || (existing_event_thread_reply_nmb && new_event_thread_reply_nmb)
          existing_forum_post.add_to_thread(self)

        # New event is a thread starter, and a reply already exists
        elsif !new_event_thread_reply_nmb && existing_event_thread_reply_nmb
          existing_forum_post.add_to_thread(self)
          make_thread_starter
        end
      end

    else
      return false
    end
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

end
