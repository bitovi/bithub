#!/usr/bin/env ruby

app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require "#{app_root}/config/environment"
require "log4r"

$log = Log4r::Logger.new('listener')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

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
        if issue.props['content_digest'] != issue_hash['content_digest']
          issue.title = issue_hash['title']
          issue.body = issue_hash['body']
          issue.props['labels'] = issue_hash['labels']
          issue.props['state'] = issue_hash['state']
          issue.props['content_digest'] = issue_hash['content_digest']
          issue.props['category'] = issue.props['labels'].first
          issue.determine_category
          issue.save!
        end
      end
    end
  end

end
