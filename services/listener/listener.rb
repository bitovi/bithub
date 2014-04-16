LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'bundler/setup'
require 'rubygems'

require 'bunny'

require 'config/environment'
require_relative 'helpers'
require 'dispatcher'
require 'logger_factory'

logger = LoggerFactory.new('listener', ENV['ENV']).component_logger
$logger = logger

class Listener

  def initialize(uri, args={})
    @conn = Bunny.new(uri).start
    @chan = @conn.create_channel
    self
  end

  def listen(queue_name, args)
    @chan
      .queue(queue_name, args)
      .subscribe(:block => true) do |delivery_info, properties, payload|
        yield ActiveSupport::JSON.decode(payload) if block_given?
    end
  end

end

Listener
  .new(ENV['RABBITMQ_URI'])
  .listen('q.events', auto_delete: true) do |payload|
    brand_name = payload.fetch('meta').fetch('brand_name')

    Apartment::Database.switch brand_name
    Dispatcher.new.dispatch payload
    Apartment::Database.switch
  end
