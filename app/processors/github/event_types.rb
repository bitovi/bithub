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

EVENT_TYPES = {
  "PushEvent" => push_event
}
