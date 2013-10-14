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
          issue.props['labels'] = issue_hash['labels']
          issue.props['state'] = issue_hash['state']
          issue.props['content_digest'] = issue_hash['content_digest']

          if issue.props['labels'] && issue.props['labels'].length > 0

            issue.props['labels'] = filter_out_junk_labels(issue.props['labels'])
            issue.props['category'] = issue.props['labels'].first
            issue.redetermine_category if issue.props['category']
          end

          issue.save!

        end
      else
        e = Event.new
  
        e.hash_key = Digest::MD5.hexdigest(issue_hash['id'].to_s + 'github') # WRONG! but only way
        e.title = issue_hash['title']
        e.body = issue_hash['body']
        e.url = issue_hash['url']
        e.category = Tag.find_or_create_by_name('issues_event')
        e.feed = Tag.find_or_create_by_name('github')

        created_at = (issue_hash['created_at']) ? issue_hash['created_at'] : (fail NoTimestampsException);
        e.origin_ts = Time.parse(created_at).utc
        e.origin_date = Time.parse(created_at).utc
        
        e.props = {
          repo_name: repo_name(issue_hash['url']),
          issue_id: issue_hash['id'],
          issue_number: issue_hash['number'],
          labels: only_names(issue_hash['labels']),
          state: issue_hash['state'],
          action: 'opened',
          feed: 'github',
          origin_author_id: issue_hash['user']['id'],
        }
          
        if issue_hash['labels'] && issue_hash['labels'].length > 0
          e.props[:labels] = filter_out_junk_labels(issue_hash['labels'])
          e.props[:category] = issue_hash['labels'].first
        else
          e.props[:category] = 'issues_event'
        end

        e.determine.save!

      end
    end
  end
end
