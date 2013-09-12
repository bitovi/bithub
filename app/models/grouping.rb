module Grouping

  def group
    group_forums.group_github.group_twitter
    self
  end

  def group_forums
    group_forum_reply if tag_list.include?('forums')
    self
  end

  def group_github
    if tag_list.include?('github')
      group_issue if tag_list.include?('issues_event')
      group_issue_comment if tag_list.include?('issue_comment_event')
      group_push_event if tag_list.include?('push_event')
      group_commit_comment if tag_list.include?('commit_comment_event')
      #group_pull_request if tag_list.include?('pull_request_event')
    end
    self
  end

  def group_twitter    
    if tag_list.include?('twitter') && tag_list.include?('status_event')

      if props[:retweeted_id]
        group_retweet
      else
        group_tweet
      end
    end

    self
  end


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

  def adopt_children_for_github_issue
    self.children += Event.collect_issue_comments(props[:issue_id])
    self
  end

  def adopt_children_for_forum_thread_starter
    thread_url, _ = url.split("#")
    self.children += Event.find_forum_thread_events_by_url(thread_url)
    self
  end

end
