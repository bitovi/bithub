module Finders
  def find_tweet_by_tweet_id(tweet_id)
    tagged_with(['twitter','status_event']).where("props -> 'tweet_id' = '#{tweet_id}'").first
  end

  def collect_retweets_of(tweet_id)
    tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{tweet_id}'")
  end

  def find_forum_thread_events_by_url(thread_url)
    tagged_with('forums').where("url LIKE '#{thread_url}%'")
  end

  def find_push_event_by_commit_id(commit_id)
    tagged_with(['github','push_event']).where("props -> 'commits' LIKE '%#{commit_id}%'").first
  end

  def find_issues_event_by_issue_id(issue_id)
    tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'").first
  end

  def find_issue_comment_event_by_issue_id(issue_id)
    tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").first
  end

  def find_commit_comment_event_by_commit_id(commit_id)
    tagged_with(['github','commit_comment_event']).where("props -> 'commit_id' = '#{commit_id}'").first
  end

  def parent_issues_event(issue_id)
    find_issues_event_by_issue_id(issue_id)
  end

  def sibling_issue_comment_event(issue_id)
    find_issue_comment_event_by_issue_id(issue_id)
  end

  def parent_push_event(commit_id)
    find_push_event_by_commit_id(commit_id)
  end

  def sibling_commit_comment_event(commit_id)
    find_commit_comment_event_by_commit_id(commit_id)
  end

  def orig_tweet(retweeted_id)
    find_tweet_by_tweet_id(retweeted_id)
  end

  def other_retweet(retweeted_id)
    find_tweet_by_tweet_id(retweeted_id)
  end

  def collect_issue_comments(issue_id)
    tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'").all
  end

  def collect_commit_comments(commits)
    tagged_with(['github','commit_comment_event']).where("position(props -> 'commit_id' in '#{commits}') > 0").all
  end
end
