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
require 'rabbit_factory'
require 'logger_factory'
require 'connection_manager'

# /app/models
require 'dispatcher'

# /LISTENER_DIR
require 'handlers'

logger = LoggerFactory.new('listener', :environment => $env).component_logger
Celluloid.logger = logger

class Listener
  include Celluloid

  def initialize(q_name, q_rk, handler_class)
    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.web')
    @q = rf.q(q_name).bind(@x, routing_key: q_rk)

    @handler = handler_class.new(self)

    Celluloid.logger.info "Listener connected to AMQP, queue name: #{q_name}"
    async.listen
  end

  def listen
    @q.subscribe do |delivery_info, properties, payload|
      packet = JSON.parse(payload)
      @handler.handle(packet)
    end
  end

  def handle_errors
    yield
  rescue => err
    Celluloid.logger.error "Error: #{err.class}, #{err.message}"
    Celluloid.logger.error "Backtrace: ----------"
    Celluloid.logger.error err.backtrace.join("\n")
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
end

Listeners.run
