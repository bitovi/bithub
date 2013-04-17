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

# Ours
require 'handlers'
require 'models/event_mongo'
require 'models/user_mongo'
require 'string'

# Connection string
$mq_cs = ENV['RABBITMQ_URI']

Mongoid.load!("config/mongoid.yml")

$handlers_mapper = {
  'github' => proc {|ev| Handler::Github.prepare_event(ev, {:feed => 'github'})},
  'forums' => proc {|ev| Handler::Forums.prepare_event(ev, {:feed => 'forums'})},
  'blog' => proc {|ev| Handler::Blog.prepare_event(ev, {:feed => 'blog'})},
  'community_site' => proc {|ev| Handler::CommunitySite.prepare_event(ev, {:feed => 'community_site'})},
  'disqus' => proc {|ev| Handler::Disqus.prepare_event(ev, {:feed => 'disqus'})},

  'twitter_public' => proc {|ev| Handler::Twitter.prepare_public_event(ev, {:feed => 'twitter'}) },
  'twitter_user' => proc {|ev| Handler::Twitter.prepare_user_event(ev, {:feed => 'twitter'}) }
}

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  channel.fanout("e.events.preproc") do |exchange|

    EventMongo.all.each do |event|
      
      puts "#{event['_id']}, #{event['feed']}, #{event['title']}"
      prepared = false

      # github, forums, blog, community_site, disqus
      if $handlers_mapper.keys.include?(event['feed']) and event['source_data']
        prepared = $handlers_mapper[event['feed']].call(event['source_data'])
      end

      # twitter events
      if event['feed'] == 'twitter'
        if event['source_data']['event'] == 'follow'
          prepared = $handlers_mapper['twitter_user'].call(event['source_data'])
        else
          prepared = $handlers_mapper['twitter_public'].call(event['source_data'])
        end
      end

      # IRC / chat
      
      if prepared
        exchange.publish(Yajl::Encoder.encode(prepared), routing_key: "tasks.taggify")
      end
      
    end
    
  end
end
