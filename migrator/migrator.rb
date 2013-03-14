$:.unshift File.dirname(__FILE__)

rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"

require 'mongoid'
require 'models/event_mongo'
require 'models/user_mongo'

Mongoid.load!("config/mongoid.yml")

$saved = 0
$failed = 0
$rejected = 0
$children = 0


def prepare_and_save(e)

  if !e[:created_ts]
    $rejected += 1
    return
  end

  event_hash = {
    body: e[:body],
    title: e[:title],
    url: e[:link],
    origin_ts: e[:created_ts].to_datetime,
    origin_date: e[:created_ts].to_date,
    hash_key: e[:hash_key],
    source_data: e[:source_data]
  }

  meta = {
    tags: e[:tags].push(e.category).push(e.feed),
    state: e[:state],
    origin_author_id: e[:actor_id],
    origin_author_gravatar_hash: e[:actor_gravatar],
    origin_author_username: e[:actor],
    feed: e[:feed],
    type: e[:type],
    category: e[:category]
  }

  ev = Event.new_with_checks(event_hash, meta)

  if ev.save
    $saved += 1
  else
    $failed += 1
  end

  ev
end

EventMongo.all.each do |e|

  if !e.hash_key || !e.category || !e.feed || !e.type
    $rejected += 1
  else
    e.children.each do |c|
      $children += 1
      prepare_and_save(c)
    end    
    prepare_and_save(e)
  end

end
  
puts "SAVED #{$saved}"
puts "FAILED #{$failed}"
puts "REJECTED #{$rejected}"
puts "CHILDREN  #{$children}"
