module Finders
  
  # Forums
  def forum_posts_by_thread_url(thread_url)
    tagged_with('forums').where("url LIKE '#{thread_url}%'")
  end


  # Twitter
  def tweets_by_tweet_id(tweet_id)
    tagged_with(['twitter','status_event']).where("props -> 'tweet_id' = '#{tweet_id}'")
  end

  def tweets_by_retweeted_id(tweet_id)
    tagged_with(['twitter','status_event']).where("props -> 'retweeted_id' = '#{tweet_id}'")
  end


  # Github
  def pushes_by_commit_sha(commit_sha)
    tagged_with(['github','push_event']).where("props -> 'commit_shas' LIKE '%#{commit_sha}%'")
  end

  def issues_by_issue_id(issue_id)
    tagged_with(['github', 'issues_event']).where("props -> 'issue_id' = '#{issue_id}'")
  end
  
  def issues_by_repo_name_and_issue_number(repo_name, issue_number)
    tagged_with(['github', 'issues_event'])
    .where("props -> 'repo_name' = '#{repo_name}'")
    .where("props -> 'issue_number' = '#{issue_number}'")
  end
  
  def name_and_number(repo_name, issue_nmb)
    where("props -> 'repo_name' = '#{repo_name}'")
    .where("props -> 'referenced_issue_number' = '#{issue_nmb}'")
  end

  def pushes_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
    tagged_with(['github', 'push_event'])
    .name_and_number(repo_name, referenced_issue_number)
  end

  def pull_requests_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
    tagged_with(['github', 'pull_request_event'])
    .name_and_number(repo_name, referenced_issue_number)
  end

  def issue_comments_by_issue_id(issue_id)
    tagged_with(['github', 'issue_comment_event']).where("props -> 'issue_id' = '#{issue_id}'")
  end
  
  def issue_comments_by_repo_name_and_issue_number(repo_name, issue_number)
    tagged_with(['github', 'issue_comment_event'])
    .where("props -> 'repo_name' = '#{repo_name}'")
    .where("props -> 'issue_number' = '#{issue_number}'")
  end

  def commit_comments_by_commit_sha(commit_sha)
    tagged_with(['github', 'commit_comment_event']).where("props -> 'commit_sha' = '#{commit_sha}'")
  end
  
  def commit_comments_by_commit_shas(commit_shas)
    tagged_with(['github', 'commit_comment_event']).where("position(props -> 'commit_sha' in '#{commit_shas}') > 0")
  end

end
