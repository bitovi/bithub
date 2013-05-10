$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'nokogiri'
require 'nori'
require 'amqp'
require 'zlib'
require 'base64'
require 'rubygems'
require 'json'
require 'mongoid'
require 'sanitize'
require 'digest/md5'

# Ours
require 'handlers'
require 'models/event_mongo'
require 'models/user_mongo'
require 'string'

# AMQP Connection string
$mq_cs = ENV['RABBITMQ_URI']

# Logging
$log = Log4r::Logger.new('migrator')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))


# IRC handler
def prepare_irc_event(ev)
  origin_ts = ev['created_ts']
  origin_date = origin_ts.strftime('%Y-%m-%d')  
  hash_key = ev['hash_key'] ? ev['hash_key'] : Digest::MD5.hexdigest(ev['type'] + ev['actor'] + origin_ts.to_s)
  
  {
    :title => ev['title'],
    :origin_ts => origin_ts,
    :origin_date => origin_date,
    :hash_key => hash_key,
    :url => ev['link'],
    :meta => {
      :origin_author_name => ev['actor'],
      :feed => 'irc',
      :category => 'chat',
      :type => ev['type']
    }
  }
end

# Disqus handler
def prepare_disqus_event(ev)
  origin_ts = ev['created_ts']
  origin_date = origin_ts.strftime('%Y-%m-%d')  

  {
    :title => ev['title'],
    :body => ev['body'],
    :origin_ts => origin_ts,
    :origin_date => origin_date,
    :hash_key => ev['hash_key'],
    :url => ev['link'],
    :meta => {
      :origin_author_name => ev['actor'],
      :feed => 'disqus',
      :category => 'comment',
    }
  }
end

# BitHub handler
def prepare_bithub_event(ev)
  origin_ts = ev['created_ts']
  origin_date = origin_ts.strftime('%Y-%m-%d')  

  hash_key = Digest::MD5.hexdigest(ev['title'] + origin_ts.to_s)
  {
    :title => ev['title'],
    :body => ev['body'],
    :origin_ts => origin_ts,
    :origin_date => origin_date,
    :hash_key => hash_key,
    :url => ev['link'],
    :meta => {
      :origin_author_name => ev['actor'],
      :feed => 'bithub',
      :type => ev['type'],
      :category => 'comment',
      :image => ev['image'],
      :tags => ev['tags']
    }
  }
end


# Mongo connection
Mongoid.load!("config/mongoid.yml")

$handlers_mapper = {
  'github' => proc {|ev| Handler::Github.prepare_event(ev, {:feed => 'github'})},
  'forums' => proc {|ev| Handler::Forums.prepare_event(ev, {:feed => 'forums'})},
  'blog' => proc {|ev| Handler::Blog.prepare_event(ev, {:feed => 'blog'})},
  #'community_site' => proc {|ev| Handler::CommunitySite.prepare_event(ev, {:feed => 'community_site'})},
  #'disqus' => proc {|ev| Handler::Disqus.prepare_event(ev, {:feed => 'disqus'})},

  'twitter_public' => proc {|ev| Handler::Twitter.prepare_public_event(ev, {:feed => 'twitter'}) },
  'twitter_user' => proc {|ev| Handler::Twitter.prepare_user_event(ev, {:feed => 'twitter'}) }
}

def prepare(event)
  prepared = false

  # github, forums, blog, community_site, disqus, irc
  if $handlers_mapper.keys.include?(event['feed']) and event['source_data']
    prepared = $handlers_mapper[event['feed']].call(event['source_data'])
  end

  # IRC
  prepared = prepare_irc_event(event) if event['feed'] == 'irc'

  # Disqus
  prepared = prepare_disqus_event(event) if event['feed'] == 'disqus'

  # BitHub
  prepared = prepare_bithub_event(event) if event['feed'] == 'bithub'
  
  # twitter events
  if event['feed'] == 'twitter' and event['source_data']
    if event['source_data']['event'] == 'follow'
      prepared = $handlers_mapper['twitter_user'].call(event['source_data'])
    else
      prepared = $handlers_mapper['twitter_public'].call(event['source_data'])
    end
  end

  prepared
end

def send2mq(exchange, prepared_event)
  exchange.publish(Yajl::Encoder.encode(prepared_event), routing_key: "tasks.taggify")
end


# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  channel.fanout("e.events.preproc") do |exchange|

    # iter all events
    EventMongo.all.each do |event|
      prepared = false

      # iter and prepare children
      if event.children
        event.children.each do |child|
          child_prepared = prepare(child)
          if child_prepared
            child_prepared[:meta][:mongo_id] = child[:_id].to_s
            send2mq(exchange, child_prepared)
          end
        end
      end

      # prepare parent
      prepared = prepare(event)
      if prepared
        prepared[:meta][:mongo_id] = event[:_id].to_s
        send2mq(exchange, prepared)
      else
        $log.info "NOT SENT | #{event['_id']}, #{event['feed']}, #{event['title']}"
      end
      
    end

  end
end
