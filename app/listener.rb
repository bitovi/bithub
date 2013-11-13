#!/usr/bin/env ruby
$: << File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'config/environment'
require 'app/listener/helpers'
require 'log4r'

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

  channel.direct("e.events") do |input_exchange|
    channel.fanout("e.events.liveservice") do |liveservice_exchange|
      queue = channel.queue("q.events").bind(input_exchange)

      queue.subscribe do |metadata, payload|

        if event_hash = ActiveSupport::JSON.decode(payload)
          log_key_attrs(event_hash)
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
  end

  channel.direct("e.issues") do |issues_exchange|
    queue = channel.queue("q.issues").bind(issues_exchange)
    queue.subscribe do |metadata, payload|

      issues_hash = ActiveSupport::JSON.decode(payload)
      issue_id = get_issue_id(issue_hash)

      if (i = Event.issues_by_issue_id(issue_id).first)
        $log.info "Updating issue with ID=#{issue_id}."

        issue = i.top_level_parent
        if (issue.props['content_digest'] != issue_hash['content_digest'])
          $log.info "Issue with ID=#{issue_hash['source_data']['id']} changed. Updating"
          issue.title = issue_hash['source_data']['title']
          issue.body = issue_hash['source_data']['body']
          issue.props['labels'] = issue_hash['source_data']['labels'].map {|l| l['name']}.join(',')
          issue.props['state'] = issue_hash['source_data']['state']
          issue.props['content_digest'] = issue_hash['content_digest']

          issue.determine_tags
          issue.determine_category

          begin
            issue.save!
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          end

        end
      else
        $log.info "Creating issue with ID=#{issue_id}."

        issue = Event.new
        action = (issue_hash['source_data']['state'] == 'open') ? 'opened' : 'closed'

        issue.hash_key = Digest::MD5.hexdigest("github:issue:#{issue_hash['source_data']['id']}")
        issue.title = issue_hash['source_data']['title']
        issue.body = issue_hash['source_data']['body']
        issue.url = issue_hash['source_data']['url']
        issue.source_data = issue_hash['source_data']
        issue.feed = Tag.find_or_create_by_name('github')

        created_at = issue_hash.andand['source_data'].andand['created_at']
        t = Time.parse(created_at).utc

        issue.origin_ts = t
        issue.origin_date = t
        issue.thread_updated_at = t
        issue.thread_updated_date = t

        issue.props = {
          repo_name: repo_name(issue_hash['source_data']['url']),
          issue_id: issue_hash['source_data']['id'],
          issue_number: issue_hash['source_data']['number'],
          labels: issue_hash['source_data']['labels'].map {|l| l['name']}.join(','),
          state: issue_hash['source_data']['state'],
          action: action,
          feed: 'github',
          type: 'issues_event',
          origin_author_id: issue_hash['source_data']['user']['id']
        }

        issue.determine

        begin
          issue.save!
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
end
