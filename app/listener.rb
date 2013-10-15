#!/usr/bin/env ruby

app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require "#{app_root}/config/environment"
require "log4r"

$log = Log4r::Logger.new('listener')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))
            

class NoRepoNameException < Exception; end
class NoTimestampsException < Exception; end


def remove_prefix(repo_name)
  repo_name.gsub(/.*\//, '')
end

def repo_name(url)
    match_groups = url.match("\/repos\/(.*)\/issues\/\d*")
    (match_groups && rn = match_groups[1]) ? rn : (fail NoRepoNameException, "no repo name pattern in the url")
end

def only_names(ls)
  ls.map {|l| l['name']}
end

def filter_out_junk_labels(ls)
  acceptable_lables = %w(bug feature feature-request enhancement)
  ls.reject{|l| l =~ /\./i}.reject{|l| !acceptable_lables.include?(l.downcase)}
end

def category_from_labels(ls)
  if ls && ls.length > 0
    filtered_ls = filter_out_junk_labels(ls)
    (!filtered_ls.nil? && !filtered_ls.empty?) ? filtered_ls.first : 'issues_event'
  else
    'issues_event'
  end
end

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  $log.info "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { $log.info "Terminating the listener"; connection.close { EM.stop }}
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.direct("e.events") do |web_exchange|  

    channel.direct("e.events.liveservice") do |liveservice_exchange|
      queue = channel.queue("q.events.web").bind(web_exchange)

      queue.subscribe do |metadata, payload|
        event_hash = ActiveSupport::JSON.decode(payload)
        meta = event_hash.delete('meta')

        begin
          ev = Event.new_from_crawler(event_hash, meta)
          ev.save!
          ev.bump_thread
          liveservice_exchange.publish(ActiveSupport::JSON.encode(ev))
        rescue ActiveRecord::RecordInvalid => invalid
          $log.info "Invalid record: #{invalid}"
        rescue ActiveRecord::RecordNotUnique => duplicate 
          $log.info "Duplicate record: #{duplicate}"
        ensure
          ev.connection.close if ev && ev.connection
        end
      end
    end
  end

  channel.fanout("e.issues") do |issues_exchange|
    queue = channel.queue("q.issues.web").bind(issues_exchange)
    queue.subscribe do |metadata, payload|
      issue_hash = ActiveSupport::JSON.decode(payload)

      if (i = Event.issues_by_issue_id(issue_hash['id']).first)
        issue = i.top_level_parent
        if (issue.props['content_digest'] != issue_hash['content_digest'])
          $log.info "Issue with ID=#{issue_hash['id']} changed. Updating"
          issue.title = issue_hash['title']
          issue.body = issue_hash['body']
          issue.props['state'] = issue_hash['state']
          issue.props['content_digest'] = issue_hash['content_digest']
          issue.props['category'] = category_from_labels(issue_hash['labels'])

          issue.redetermine_category
          issue.save!
        end
      else
        $log.info "Issue with ID=#{issue_hash['id']} doesn't exist. Creating"
        issue = Event.new
        action = (issue_hash['state'] == 'open') ? 'opened' : 'closed'
  
        issue.hash_key = Digest::MD5.hexdigest("github:issue:#{issue_hash['id']}")
        issue.title = issue_hash['title']
        issue.body = issue_hash['body']
        issue.url = issue_hash['url']
        issue.feed = Tag.find_or_create_by_name('github')

        created_at = (issue_hash['created_at']) ? issue_hash['created_at'] : (fail NoTimestampsException);
        t = Time.parse(created_at).utc

        issue.origin_ts = t
        issue.origin_date = t
        issue.thread_updated_at = t
        issue.thread_updated_date = t
        
        issue.props = {
          repo_name: repo_name(issue_hash['url']),
          issue_id: issue_hash['id'],
          issue_number: issue_hash['number'],
          labels: only_names(issue_hash['labels']),
          state: issue_hash['state'],
          action: action,
          feed: 'github',
          type: 'issues_event',
          origin_author_id: issue_hash['user']['id'],
          tags: [ remove_prefix(repo_name(issue_hash['url'])) ]
        }
          
        issue.props['category'] = category_from_labels(issue_hash['labels'])
        issue.determine
        issue.save!
      end
    end
  end
end
