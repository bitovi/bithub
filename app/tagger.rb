$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'amqp'
require 'json'

# Ours
require 'tagger/tagger'

DEFAULT_TAGS = ['canjs', 'canui', 'javascriptmvc', 'donejs', 'stealjs', 'funcunit', 'jquerypp']

# Calculate project root path
$proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../'))

# Connection string
$mq_cs = ENV['MSGQ']

# Load rules
$rules = YAML::load_file(File.join($proj_root, 'config/rules.yml'))

# Load tags
$tags = DEFAULT_TAGS

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  # Trap ctrl-c
  stop = proc { puts "Terminating tagger"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  # Tagger instance
  tagger = Tagger::Base.new(nil, $rules, $tags)

  # MQ receiver
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("q.events.tagger").bind("e.events.preproc", {:routing_key => "tasks.taggify"})
  queue.subscribe do |metadata, payload|
    EM.defer do
      event = JSON.parse(payload, {:symbolize_names => true})

      # set tags over event url, title and body
      search_text = (event[:url] || '') + ' ' + event[:title] + ' ' + (event[:body] || '')
      event[:meta][:tags] = tagger.find_tags(search_text)

      # determine category from event tags, feed and type
      search_tags = event[:meta][:tags].clone
      search_tags <<= event[:meta][:feed]
      search_tags <<= event[:meta][:type] if event[:meta][:type]
      event[:meta][:category] = tagger.determine_category(search_tags)
      
    end
  end

  # produce
  #exchange = channel.fanout("e.events")  
end
