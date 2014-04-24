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
    @logger = LoggerFactory.new('listener', :environment => ENV['ENV']).component_logger
    @logger.info 'Starting listener'

    @conn = Bunny.new(uri).start
    @chan = @conn.create_channel

    @logger.info 'Listener connected to AMQP'

    self
  end

  def listen(queue_name, args={})
    @chan
      .queue(queue_name, args)
      .subscribe(:block => true) do |delivery_info, properties, payload|
        yield ActiveSupport::JSON.decode(payload), @logger if block_given?
      end
  end
end


Listener
  .new(ENV['RABBITMQ_URI'])
  .listen('q.events') do |payload, logger|
    meta           = payload.fetch('meta')
    brand_name     = meta.fetch('brand_name').to_s
    feed_name      = meta.fetch('type_name')
    type_name      = meta.fetch('feed_name')
    content_digest = payload.fetch('content_digest')

    logger.info "(#{content_digest}) New message received; brand: '#{brand_name}', feed: '#{feed_name}', type: '#{type_name}'"

    Apartment::Database.switch brand_name
    logger.debug "(#{content_digest}) Current tenant switched to #{Apartment::Database.current_tenant}"

    # Catch any possible errors
    # (errors inside bunny listen method won't be logged :/)
    begin
      Dispatcher.new(logger: logger).dispatch payload
    rescue Exception => err
      logger.error "(#{content_digest}) Dispatching failed: #{err.message}"
      logger.error err.backtrace.join("\n")
    else
      logger.info "(#{content_digest}) Dispatching successful"
    end

    Apartment::Database.switch
    logger.debug "(#{content_digest}) Current tenant switched back to #{Apartment::Database.current_tenant}"
  end
