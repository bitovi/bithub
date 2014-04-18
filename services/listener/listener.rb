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

class Listener

  def initialize(uri=ENV['RABBITMQ_URI'])
    @logger = LoggerFactory.new('listener', ENV['ENV']).component_logger
    @logger.info 'Starting listener'

    @conn = Bunny.new(uri).start
    @chan = @conn.create_channel

    @logger.info 'Listener connected to AMQP'

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
    meta           = payload.fetch('meta')
    brand_name     = meta.fetch('brand_name')
    feed_name      = meta.fetch('type_name')
    type_name      = meta.fetch('feed_name')
    content_digest = payload.fetch('content_digest')

    @logger.info "--> Received new message '#{content_digest}', brand: '#{brand_name}', feed: '#{feed_name}', type: '#{type_name}'"

    Apartment::Database.switch brand_name
    @logger.debug "(#{content_digest}) Current tenant switched to #{Apartment::Database.current_tenant}"

    Dispatcher.new.dispatch payload

    Apartment::Database.switch
    @logger.debug "(#{content_digest}) Current tenant switched back to #{Apartment::Database.current_tenant}"
  end
