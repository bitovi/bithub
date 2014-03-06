IRCBOT_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(IRCBOT_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

# Theirs
require 'bundler/setup'
require 'rubygems'
require 'amqp'
require 'yaml'
require 'yajl'
require 'cinch'
require 'logger_factory'

# Loggers
logger = LoggerFactory.new('irc_bot', ENV['ENV']).component_logger
$logger = logger

# paths to config files based on env
config_path = File.join(ROOT_DIR, 'config', 'services', 'irc_bot', "#{ENV['ENV']}.yml")

# Load config
$mq_cs = ENV['RABBITMQ_URI']
$config = YAML::load_file(config_path)

### Helpers

def message_processor(msg)
  {
    channel: msg.channel.to_s,
    nickname: msg.user.nick,
    message: msg.message,
    ts: msg.time.utc
  }
end

def make_payload(msg)
  sd = message_processor(msg)
  {
    source_data: sd,
    meta: {
      feed_name: 'irc',
      type_name: 'message'
    }
  }
end


### Handlers

def publish(msg)
  payload = make_payload(msg)

  $logger.info "New message: \"#{payload[:source_data][:message]}\" from #{payload[:source_data][:nickname]}"

  # for every message new connection to AMQP is opened and immediately
  # closed after publishing b/c thread vs. EM issues, read -->
  # http://rubyamqp.info/articles/working_with_exchanges/#toc_35

  EventMachine.run do
    connection = AMQP.connect($mq_cs)
    channel    = AMQP::Channel.new(connection)
    exchange   = channel.direct("e.events")

    exchange.publish(Yajl::Encoder.encode(payload)) do
      connection.close { EventMachine.stop }
    end

  end
end


###  Configure and start IRC bot

bot = Cinch::Bot.new do
  configure do |c|
    c.server = $config['server']
    c.channels = $config['channels']
    c.nick = $config['nick'] || 'bithub-bot'
  end
end

bot.on :message do |msg|
  publish(msg)
end

$logger.info "Starting IRC bot"
bot.start
