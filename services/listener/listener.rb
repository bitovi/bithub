ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))

require 'bundler/setup'
require 'rubygems'
require 'bunny'
require 'config/environment'
require 'dispatcher'
require 'logger_factory'
require 'celluloid'
require 'lib/rabbit_factory'
require_relative 'helpers'

class Listener
  include Celluloid

  def initialize(q_name, q_opts, fn)
    routing_key = q_opts.fetch(:routing_key) { '' }
    @conn = Bunny.new(ENV['RABBITMQ_URI']).start
    @chan = @conn.create_channel
    $rabbitmq = @chan

    rf = RabbitFactory.new(@chan)
    @x = rf.x('x.web', :direct)
    @q = rf.q(q_name).bind(@x, routing_key: routing_key)
    @fn = fn

    Celluloid.logger.info "Listener connected to AMQP, queue name: #{q_name}"
    async.listen
  end

  def listen
    @q.subscribe(block: true) do |delivery_info, properties, payload|
      @fn.(ActiveSupport::JSON.decode(payload))
    end
  end
end

class Listeners < Celluloid::SupervisionGroup
  supervise Listener, as: :error_l, args: ['q.web.errors', { routing_key: 'errors' }, ->(packet) do
    meta           = packet.fetch('meta')
    payload        = packet.fetch('payload')
    brand_name     = meta.fetch('brand_name')

    Celluloid.logger.info "New error received; brand: '#{brand_name}', payload: #{payload}"

    begin
      Apartment::Tenant.switch(brand_name) { ServiceError.new(payload).save! }
    rescue ValidationError => err
      Celluloid.logger.error "ValidationError: #{err.message}"
    rescue StandardError => err
      Celluloid.logger.error "Saving ServiceError failed: #{err.message}"
      Celluloid.logger.error err.backtrace.join("\n")
    ensure
      Apartment::Tenant.switch! # either way switch back to public
    end
  end]

  supervise Listener, as: :event_l, args: ['q.web.events', { routing_key: 'events' }, ->(payload) do
    meta           = payload.fetch('meta')
    content_digest = payload.fetch('content_digest')
    brand_name     = meta.fetch('brand_name')
    embed_name     = meta.fetch('embed_name')
    feed_name      = meta.fetch('feed_name')
    type_name      = meta.fetch('type_name')

    Celluloid.logger.info "New event received; digest: '#{content_digest}', brand: '#{brand_name}', embed: '#{embed_name}', feed: '#{feed_name}', type: '#{type_name}'"

    begin
      Apartment::Tenant.switch(brand_name) { Dispatcher.new(logger: Celluloid.logger).dispatch(payload) }
      Celluloid.logger.info "(#{content_digest}) Dispatching finished"
    rescue StandardError => err
      Celluloid.logger.error "(#{content_digest}) Dispatching failed: #{err.message}"
      Celluloid.logger.error err.backtrace.join("\n")
    ensure
      Apartment::Tenant.switch! # either way switch back to public
    end
  end]
end

Listeners.run
