require 'connection_manager'
require 'rabbit_factory'
require 'newrelic_rpm'

class NotificationPublisher
  include Celluloid
  include Celluloid::Logger
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def initialize
    Celluloid.logger.info 'Initializing Notification publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x_frontend = rf.x('x.liveservice', :direct)
    @q_frontend = rf.q('q.liveservice.services').bind(@x_frontend, routing_key: 'services')

    @x_backend = rf.x('x.web', :direct)
    @q_backend = rf.q('q.web.commands').bind(@x_backend, routing_key: 'commands')
  end

  def publish_to_frontend(notif)
    info "Publishing COMMAND #{notif.fetch(:payload)} to frontend"
    @x_frontend.publish(notif.to_json, routing_key: 'services')
  end
  alias_method :publish, :publish_to_frontend
  add_transaction_tracer :publish, :category => 'OtherTransaction/Publishers'

  def publish_to_backend(notif)
    info "Publishing COMMAND #{notif.fetch(:payload)} to backend"
    @x_backend.publish(notif.to_json, routing_key: 'commands')
  end
end
