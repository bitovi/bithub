$:.unshift File.dirname(__FILE__)

rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"

require 'mongoid'
require 'models/event_mongo'
require 'models/user_mongo'

Mongoid.load!("config/mongoid.yml")

EventMongo.all.each do |e|
  event_hash = {
    body: e.body,
    title: e.title,
    url: e.link,
    origin_ts: e.created_ts,
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

  ev = Event.new(event_hash)
  ev.meta = meta
  puts ev.to_yaml
  ev.whole_chain
end
