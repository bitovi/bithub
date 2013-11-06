require 'digest/md5'

class GithubProcessor

  def initialize(config = {})
  end

  def process(original_hash, partly_processed_hash)
    if github_event?(original_hash)
      event_type = original_hash['type'].snake_case
      process_github_event(event_type, original_hash, partly_processed_hash)
    elsif github_issue?(original_hash)
      process_github_issue(original_hash)
    else
      fail Processor::InvalidEventException, "not an event nor an issue"
    end
  end

  def origin_timestamps(original_hash)
    fail_if_invalid(original_hash)
    Time.parse(datetime_str(original_hash)).utc
  end
  
  def unique_attribute(original_hash)
    (original_hash[:id] || original_hash['id']).to_s
  end
  
  def events_from_response(response)
    response
  end

  private

  def fail_if_invalid(original_hash)
    fail Processor::InvalidEventException, "not an event nor an issue" if not(event_or_issue?(original_hash))
  end

  def event_or_issue?(origin_hash)
    github_event?(origin_hash) || github_issue?(origin_hash)
  end

  def github_event?(event_hash)
    not(event_hash['type'].nil?)
  end
  
  def github_issue?(issue_hash)
    not(issue_hash['labels'].nil?)
  end
  
  def datetime_str(original_hash)
    (str = original_hash['created_at']) ? str : (fail Processor::MissingTimestamp, "missing origin timestamps");
  end

  def process_github_issue(issue_hash)
    composite_seed = issue_hash['id'].to_s +
                     issue_hash['labels'].to_s +
                     issue_hash['state'] +
                     issue_hash['title'] +
                     issue_hash['body']

    issue_hash['content_digest'] = Digest::MD5.hexdigest(composite_seed)
    issue_hash['label_names'] = issue_hash['labels'].map{|l| l['name']}
    issue_hash
  end

  def process_github_event(event_type, original_hash, partly_processed_hash)

    partly_processed_hash
    .deep_merge({
      meta: {
        feed: 'github',
        type: event_type,
        origin_id: original_hash['id'],
        origin_author_name: original_hash['actor']['login'],
        origin_author_id: original_hash['actor']['id'],
        origin_author_gravatar: original_hash['actor']['gravatar_id'],
      }
    })
    .deep_merge(self.send(event_type.to_sym, original_hash))
  end

  def commit_comment_event(event)
    return {
      :title => "commented on a commit in #{event['repo']['name']}",
      :body => event['payload']['comment']['body'],
      :url => event['payload']['comment']['html_url'],
      :meta => { :commit_id => event['payload']['comment']['commit_id'] }
    }
  end

  def create_event(event)
    return {
      :title => "created a new #{event['payload']['ref_type']} on #{event['repo']['name']}: #{event['payload']['ref']}"
    }
  end

  def delete_event (event)
    return {
      :title => "deleted a #{event['payload']['ref_type']} from #{event['repo']['name']}: #{event['payload']['ref']}"
    }
  end

  def download_event (event)
    return {
      :title => "download #{event['payload']['download']['name']} created",
      :body => event['payload']['download']['description'],
      :url => event['payload']['download']['html_url']
    }
  end

  def follow_event (event)
    return {
      :title => "followed #{event['repo']['name']}"
    }
  end

  def fork_event (event)
    return {
      :title => "forked #{event['repo']['name']}"
    }
  end

  def fork_apply_event (event)
    return {
      :title => "patch applied on #{event['repo']['name']}"
    }
  end

  def gist_event (event)
    return {
      :title => "Gist #{event['payload']['action']}: #{event['payload']['gist']['description']}",
      :url => event['payload']['gist']['url'],
        :meta => {
        :action => event['payload']['action']
      }
    }
  end

  def gollum_event (event)
    issue_hash = {
      :title => "gollum event",
      :meta => { :pages => [] }
    }

    event['payload']['pages'].each do |page|
      issue_hash[:meta][:pages].push({:title => page['title'], :url => page['html_url']})
    end

    issue_hash
  end

  def issue_comment_event (event)
    return {
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

  def issues_event (event)
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

    return {
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

  def member_event (event)
    return {
      :title => "Member #{event['payload']['member']['login']} added to #{event['repo']['name']}"
    }
  end

  def public_event (event)
    return {
      :title => "Repository #{event['repo']['name']} goes public!"
    }
  end

  def pull_request_event (event)
    if m = ("" + event['payload']['pull_request']['title'] + event['payload']['pull_request']['body']).match(/#(\d*)/)
      issue_nmb = m[1]
    end

    t = event['payload']['pull_request']['title']
    nmb = event['payload']['pull_request']['number']
    state = event['payload']['pull_request']['state']
    action = event['payload']['action']

    title = "Pull request ##{nmb} #{action}: #{t}"

    return {
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

  def pull_request_review_comment_event (event)
    return {
      :title => "commented on pull request review #{event['payload']['issue']['number']}",
      :url => event['payload']['comment']['_links']['html'],
      :body => event['payload']['comment']['body']
    }
  end

  def push_event (event)
    if m = (event['payload']['commits'].map{|c| c['message']}.join(' ')).match(/#(\d*)/)
      issue_nmb = m[1]
    end

    issue_hash = {
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

    issue_hash
  end

  def team_add_event (event)
    return {
      :title => "team add event"
    }
  end

  def watch_event (event)
    return {
      :title => "started watching #{event['repo']['name']}",
      :hash_key => Digest::MD5.hexdigest(event['actor']['id'].to_s + event['repo']['id'].to_s + 'github')
    }
  end

end
