LISTENER_DIR = File.dirname(__FILE__)
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))

$:.unshift(LISTENER_DIR)
$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))
$:.unshift(File.join(ROOT_DIR, 'lib'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'

# /
require 'config/environment'

# /lib
require 'core_ext'
require 'rabbit_helper'
require 'logger_factory'
require 'connection_manager'

# /app/models
require 'dispatcher'

# /LISTENER_DIR
require 'handlers/error_handler'
require 'handlers/command_handler'
require 'handlers/event_handler'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('listener', :environment => $env).component_logger
Celluloid.logger = logger

class Listener
  include Celluloid
  include Celluloid::Logger

  def initialize(q_name, q_rk, handler_class)
    rf = RabbitHelper.new(ConnectionManager.instance.rabbit)
    @c = rf.chan
    @x = rf.x('x.web')
    @q = rf.q(q_name).bind(@x, routing_key: q_rk)

    @handler = handler_class.new(self)

    Celluloid.logger.info "Listener connected to AMQP, queue name: #{q_name}"

    every(5) do
      info "Listener with #{@handler.class} mailbox size #{Actor.current.mailbox.size}"
    end

    async.listen
  end

  def listen
    @q.subscribe(manual_ack: true, block: false) do |delivery_info, properties, payload|
      packet = JSON.parse payload
      @handler.handle packet
      @c.acknowledge delivery_info.delivery_tag, false
    end
  end

  def handle_errors
    yield
  rescue => err
    error "Error: #{err.class}, #{err.message}"
    error "Backtrace: ----------"
    error err.backtrace.join("\n")
  ensure
    Apartment::Tenant.switch! # either way switch back to public
  end
end

class Listeners < Celluloid::SupervisionGroup
  supervise(
    Listener,
    as: :error_listener,
    args: ['q.web.errors', 'errors', ErrorHandler]
  )

  supervise(
    Listener,
    as: :event_listener,
    args: ['q.web.events', 'events', EventHandler]
  )

  supervise(
    Listener,
    as: :command_listener,
    args: ['q.web.commands', 'commands', CommandHandler]
  )
end

Listeners.run
