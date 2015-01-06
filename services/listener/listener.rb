ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))

require 'bundler/setup'
require 'rubygems'
require 'bunny'
require 'config/environment'
require 'dispatcher'
require 'logger_factory'
require_relative 'helpers'

class Listener
  def initialize(uri=ENV['RABBITMQ_URI'])
    @logger = LoggerFactory.new('listener', :environment => ENV['ENV']).component_logger
    @logger.info 'Starting listener'

    @conn = Bunny.new(uri).start
    @chan = @conn.create_channel

    @logger.info 'Listener connected to AMQP'
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
    brand_name     = meta.fetch('brand_name')
    embed_name     = meta.fetch('embed_name')
    feed_name      = meta.fetch('feed_name')
    type_name      = meta.fetch('type_name')
    content_digest = payload.fetch('content_digest')

    logger.info "(#{content_digest}) New message received; brand: '#{brand_name}', embed: '#{embed_name}', feed: '#{feed_name}', type: '#{type_name}'"

    Apartment::Tenant.switch brand_name
    logger.debug "(#{content_digest}) Current tenant switched to #{Apartment::Tenant.current}"

    # Catch any possible errors
    # (errors inside bunny listen method won't be logged :/)
    begin
      Dispatcher.new(logger: logger).dispatch payload
      logger.info "(#{content_digest}) Dispatching finished"
    rescue Exception => err
      logger.error "(#{content_digest}) Dispatching failed: #{err.message}"
      logger.error err.backtrace.join("\n")
    end

    Apartment::Tenant.switch
    logger.debug "(#{content_digest}) Current tenant switched back to #{Apartment::Tenant.current}"
  end
