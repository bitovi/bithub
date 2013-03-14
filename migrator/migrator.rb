$:.unshift File.dirname(__FILE__)

rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"

require 'mongoid'
require 'models/event_mongo'
require 'models/user_mongo'

Mongoid.load!("config/mongoid.yml")

count = 0
EventMongo.all.reject {|e| !e.hash_key || !e.category || !e.feed || !e.type }.each do |e|

  event_hash = {
    body: e.body,
    title: e.title,
    url: e.link,
    origin_ts: e.created_ts.to_datetime,
    origin_date: e.created_ts.to_date,
    hash_key: e.hash_key,
    source_data: e.source_data
  }

  meta = {
    tags: e.tags.push(e.category).push(e.feed),
    state: e.state,
    origin_author_id: e.actor_id,
    origin_author_gravatar_hash: e.actor_gravatar,
    origin_author_username: e.actor,
    feed: e.feed,
    type: e.type,
    category: e.category
  }

  ev = Event.new_with_checks(event_hash, meta)
  if !ev.save
    count += 1
  end
end
  
puts "SKIPPED #{count}"
