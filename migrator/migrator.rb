$:.unshift File.dirname(__FILE__)

rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"

require 'mongoid'
require 'models/event_mongo'
require 'models/user_mongo'

Mongoid.load!("config/mongoid.yml")


class String
  def snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end


# counters
$count = 0
$saved = 0
$failed = 0
$rejected = 0

$children_count = 0
$children_saved = 0
$children_failed = 0
$children_rejected = 0

$duplicates = 0

# DISTINCT from Mongo

$feeds = {
  "github" => "github",
  "disqus" => "disqus",
  "forums" => "forums",
  "community_site" => "community_site",
  "irc" => "irc",
  "twitter" => "twitter",
  "bithub" => "bithub",
  "blog" => "blog"
}

$types = {
  "watchevent" => "watch_event",
  "deleteevent" => "delete_event",
  "pushevent" => "push_event",
  "pullrequestevent" => "pull_request_event",
  "createevent" => "create_event",
  "issuesevent" => "issues_event",
  "commitcommentevent" => "commit_comment_event",
  "issuecommentevent" => "issue_comment_event",
  "canjs" => "canjs",
  "general javascriptmvc" => "general_javascriptmvc",
  "#canjs" => "canjs",
  "forkevent" => "fork_event",
  "follow_event" => "follow_event",
  "status_event" => "status_event",
  "app" => "app",
  "gollumevent" => "gollum_event",
  "pullrequestreviewcommentevent" => "pull_request_review_comment_event",
  "stealjs" => "stealjs",
  "jquerymx" => "jquerymx",
  "funcunit" => "funcunit",
  "article" => "article",
  "jquery++" => "jquerypp",
  "publicevent" => "public_event",
  "plugin" => "plugin",
  "#bitovi" => "bitovi"
}

$categories = {
  "digest" => "digest",
  "code" => "code",
  "comment" => "comment",
  "chat" => "chat",
  "twitter" => "twitter",
  #null,
  "bug" => "bug",
  "question" => "question",
  "article" => "article",
  "plugin" => "plugin",
  "app" => "app"
}

def determine_category(meta)

  # twitter
  if meta[:feed] == 'twitter'
    if meta[:type] == 'follow_event'
      meta[:category] = 'digest'
    else
      meta[:category] = 'twitter'
    end

  # github
  elsif meta[:feed] == 'github'
    if ['commit_comment_event', 'issue_comment_event', 'pull_request_review_comment_event'].include?(meta[:type])
      meta[:category] = 'comment'
    elsif ['fork_event', 'watch_event'].include?(meta[:type])
      meta[:category] = 'digest'
    elsif ['push_event', 'create_event', 'delete_event', 'pull_request_event'].include?(meta[:type])
      meta[:category] = 'code'
    elsif meta[:labels]
      if (meta[:labels] & ['bug', 'Bug']).length > 0
        meta[:category] = 'bug'
      elsif (meta[:labels] & ['feature', 'Feature', 'feature-request','enhancement']).length > 0
        meta[:category] = 'feature'
      elsif (meta[:labels] & ['question', 'Question']).length > 0
        meta[:category] = 'question'
      end
    elsif ['closed', 'open', 'reopened'].include?(meta[:state])
      meta[:category] = 'bug'
    end

  # irc
  elsif meta[:feed] == 'irc'
    meta[:category] = 'chat'

  # disqus
  elsif meta[:feed] == 'disqus'
    meta[:category] = 'comment'

  # blog
  elsif meta[:feed] == 'blog'
    meta[:category] = 'article'

  # forums
  elsif meta[:feed] == 'forums'
    meta[:category] = 'question'
  end

  # failover
  meta[:category] = 'unknown' unless meta[:category]
  
  meta[:category]
end


def prepare_and_build(event)

  if !event['hash_key']
    return false
  end

  if Event.where(:hash_key => event['hash_key']).length > 0
    $duplicates += 1
    return false
  end

  event_hash = {
    body: event['body'],
    title: event['title'],
    url: event['link'],
    origin_ts: event['created_ts'].to_datetime,
    origin_date: event['created_ts'].to_date,
    hash_key: event['hash_key'],
    source_data: event['source_data']
  }

  meta = {
    #tags: event[:tags].push(event[:category]).push(event[:feed]).push(event[:type]),
    state: event['state'],
    origin_author_id: event['actor_id'],
    origin_author_gravatar_hash: event['actor_gravatar'],
    origin_author_username: event['actor'],
    #feed: event[:feed],
    #type: event[:type],
    #category: event[:category]
  }

  # tags
  meta[:tags] = event['tags']

  # feed
  meta[:feed] = $feeds[event['feed']]
  meta[:tags].push(meta[:feed])

  # type
  if event['type'] then 
    meta[:type] = $types[event['type']] 
    meta[:tags].push(meta[:type])
  end
  
  # category
  if !meta[:category]
    meta[:category] = determine_category(meta)
  end
  meta[:tags].push(meta[:category])

  # update origin_ts for forum events
  if meta[:feed] == 'forums'
    event_hash[:origin_ts] = event['source_data']['pubDate'].to_datetime
    event_hash[:origin_date] = event['source_data']['pubDate'].to_date
  end

  # for twitter set up tweet_id and retweeted_id
  if meta[:type] == 'status_event'
    meta[:tweet_id] = event['source_data']['id_str']
    if event['source_data']['retweeted_status']
      meta[:retweeted_id] = event['source_data']['retweeted_status']['id_str'] 
    end
  end

  # set issue_id for github issues events
  if ['issues_event','issue_comment_event'].include?(meta[:type])
    meta[:issue_id] = event['issue_id']
  end

  # set commit_id for github push_event and commit_comment_event
  if meta[:type] == 'push_event'
    meta[:commits] = ""
    event['source_data']['payload']['commits'].each do |commit|
      meta[:commits] += commit['sha'] + ','
    end
  end
  if meta[:type] == 'commit_comment_event'
    meta[:commit_id] = event['source_data']['payload']['comment']['commit_id']
  end
  
  # PRINT OUT events with undetermined category
  if meta[:category] == 'unknown'
    puts "CATEGORY: #{meta[:category]} \tFEED: #{meta[:feed]} \tTYPE: #{meta[:type]} \tLABELS: #{meta[:labels]} \tSTATE: #{meta[:state]}"
  end

  Event.new_with_checks(event_hash, meta)
end

EventMongo.all.each do |e|
  $count += 1

  # prepare event/parent
  if parent = prepare_and_build(e)

    # save
    if parent.save!
      $saved += 1
    else
      $failed += 1
    end

    # iter children
    e.children.each do |c|
      $children_count += 1

      # prepare child
      if child = prepare_and_build(c)
        # save child
        if child.save!
          $children_saved += 1
        else
          $children_failed += 1
        end
      else
        $children_rejected += 1
      end
    end

  else
    $rejected += 1
  end
  
end


puts "PARENT COUNT #{$count}"
puts "PARENT SAVED #{$saved}"
puts "PARENT FAILED #{$failed}"
puts "PARENT REJECTED #{$rejected}"

puts "============"
puts "CHILDREN COUNT  #{$children_count}"
puts "CHILDREN SAVED  #{$children_saved}"
puts "CHILDREN REJECTED  #{$children_rejected}"
puts "CHILDREN FAILED  #{$children_failed}"

puts "============"
puts "DUPLICATES  #{$duplicates}"
