require 'digest/md5'

commit_comment_event = lambda do |event|
  {
    :title => "commented on a commit in #{event['repo']['name']}",
    :body => event['payload']['comment']['body'],
    :url => event['payload']['comment']['html_url'],
    :meta => { :commit_id => event['payload']['comment']['commit_id'] }
  }
end

create_event = lambda do |event|
  { :title => "created created a new #{event['payload']['ref_type']} in #{event['repo']['name']}" }
end

delete_event = lambda do |event|
  { :title => "deleted a #{event['payload']['ref_type']} from #{event['repo']['name']}" }
end

download_event = lambda do |event|
  {
    :title => "download #{event['payload']['download']['name']} created",
    :body => event['payload']['download']['description'],
    :url => event['payload']['download']['html_url']
  }
end

follow_event = lambda do |event|
  { :title => "followed #{event['repo']['name']}" }
end

fork_event = lambda do |event|
  { :title => "forked #{event['repo']['name']}" }
end

fork_apply_event = lambda do |event|
  { :title => "patch applied on #{event['repo']['name']}" }
end

gist_event = lambda do |event|
  {
    :title => "Gist #{event['payload']['action']}: #{event['payload']['gist']['description']}",
    :url => event['payload']['gist']['url'],
    :meta => {
      :action => event['payload']['action']
    }
  }
end

gollum_event = lambda do |event|
  event_hash = {
    :title => "gollum event",
    :meta => { :pages => [] }
  }

  event['payload']['pages'].each do |page|
    event_hash[:meta][:pages].push({:title => page['title'], :url => page['html_url']})
  end

  event_hash
end

issue_comment_event = lambda do |event|
  {
    :title => "commented on issue #{event['payload']['issue']['number']}",
    :body => event['payload']['comment']['body'],
    :url => event['payload']['issue']['html_url'],
    :meta => {
      :labels => event['payload']['issue']['labels'].map { |l| l['name'] },
      :issue_id => event['payload']['issue']['id'],
      :issue_number => event['payload']['issue']['number'],
      :repo_name => event['repo']['name']
    }
  }
end

issues_event = lambda do |event|

  t = event['payload']['issue']['title']
  nmb = event['payload']['issue']['number']
  state = event['payload']['issue']['state']
  action = event['payload']['action']

  if action == 'opened'
    title = t
  else
    title = "Issue #{action}: #{t}"
  end

  composite_seed = event['payload']['issue']['id'].to_s +
                   event['payload']['issue']['labels'].to_s +
                   event['payload']['issue']['state'] +
                   event['payload']['issue']['title'] +
                   event['payload']['issue']['body']

  {
    :title => title,
    :body => event['payload']['issue']['body'],
    :url => event['payload']['issue']['html_url'],
    :meta => {
      :content_digest => Digest::MD5.hexdigest(composite_seed),
      :labels => event['payload']['issue']['labels'].map { |l| l['name'] },
      :issue_id => event['payload']['issue']['id'],
      :action => event['payload']['action'],
      :repo_name => event['repo']['name'],
      :state => state,
      :issue_number => nmb
    }
  }
end

member_event = lambda do |event|
  { :title => "Member #{event['payload']['member']['login']} added to #{event['repo']['name']}" }
end

public_event = lambda do |event|
  { :title => "Repository #{event['repo']['name']} goes public!" }
end

pull_request_event = lambda do |event|

  if m = ("" + event['payload']['pull_request']['title'] + event['payload']['pull_request']['body']).match(/#(\d*)/)
    issue_nmb = m[1]
  end
  
  t = event['payload']['pull_request']['title']
  nmb = event['payload']['pull_request']['number']
  state = event['payload']['pull_request']['state']
  action = event['payload']['action']

  title = "Pull request ##{nmb} #{action}: #{t}"
  
  event_hash = {
    :title => title,
    :body => event['payload']['pull_request']['body'],
    :url => event['payload']['pull_request']['html_url'],
    :meta => {
      :repo_name => event['repo']['name'],
      :referenced_issue_number => issue_nmb,
      :issue_number => nmb,
      :action => action,
      :state => state

    }
  }
end

pull_request_review_comment_event = lambda do |event|
  {
    :title => "commented on pull request review #{event['payload']['issue']['number']}",
    :url => event['payload']['comment']['_links']['html'],
    :body => event['payload']['comment']['body']
  }
end

push_event = lambda do |event|
  if m = (event['payload']['commits'].map{|c| c['message']}.join(' ')).match(/#(\d*)/)
    issue_nmb = m[1]
  end

  event_hash = {
    :title => "pushed to #{event['repo']['name']}",
    :body => event['payload']['body'],
    :url => "http://github.com/#{event['repo']['name']}/commit/#{event['payload']['head']}",
    :meta => {
      :commits => event['payload']['commits'].map{|c| c['sha']}.join(','),
      :commit_shas => event['payload']['commits'].map{|c| c['sha']}.join(','),
      :repo_name => event['repo']['name'],
      :referenced_issue_number => issue_nmb
    }
  }

  event_hash
end

team_add_event = lambda do |event|
  { :title => "team add event" }
end

watch_event = lambda do |event|
  {
    :title => "started watching #{event['repo']['name']}",
    :hash_key => Digest::MD5.hexdigest(event['actor']['id'].to_s + event['repo']['id'].to_s + 'github')
  }

end

EVENT_TYPES = {
  commit_comment_event: commit_comment_event,
  create_event: create_event,
  delete_event: delete_event,
  download_event: download_event,
  follow_event: follow_event,
  fork_event: fork_event,
  fork_apply_event: fork_apply_event,
  gist_event: gist_event,
  gollum_event: gollum_event,
  issue_comment_event: issue_comment_event,
  issues_event: issues_event,
  member_event: member_event,
  public_event: public_event,
  pull_request_event: pull_request_event,
  pull_request_review_comment_event: pull_request_review_comment_event,
  push_event: push_event,
  team_add_event: team_add_event,
  watch_event: watch_event
}
