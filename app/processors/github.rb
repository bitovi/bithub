require "#{Rails.root}/lib/hash"
require "#{Rails.root}/lib/string"

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

custom_commit_event = lambda do |event|
  if m = (event['payload']['commits'].map{|c| c['message']}.join(' ')).match(/#(\d*)/)
    issue_nmb = m[1]
  end

  lines = event['message'].lines.map(&:chomp)
  title = lines[0]
  body = lines[2..-1]
  
  event_hash = {
    :title => title,
    :body => body,
    :url => event['url'],
    :hash_key => event['sha'],
    :meta => {
      :category => 'code',
      :repo_name => event['repo']['name'],
      :referenced_issue_number => issue_nmb
    }
  }

  event_hash
end

EVENT_TYPES = {
  "PushEvent" => push_event,
  "CustomCommitEvent" => custom_commit_event
}

module Processors
  class Github
    class NotValidEventException < Exception; end
    attr_reader :feed

    def initialize(opts)
      @feed = opts[:feed]
    end

    def process(event_hash)
      # Github provides date in format: "2013-02-14T22:47:29Z"
      parsed_date = Time.parse(event_hash[:created_at]).utc

      processed_event_hash = {
        origin_ts: parsed_date.iso8601,
        origin_date: parsed_date.strftime("%Y-%m-%d"),
        hash_key: event_hash[:hash_key],
        source_data: event_hash,
        meta: {
          type: event_hash[:type].snake_case,
          feed: feed,
          origin_id: event_hash[:id],
          origin_author_name: event_hash[:actor][:login],
          origin_author_id: event_hash[:actor][:id],
          origin_author_gravatar: event_hash[:actor][:gravatar_id]
        }
      }

      t = event_hash[:type]
      processed_event_hash.deep_merge(EVENT_TYPES[t].call(event_hash))
    end
  end
end
