require 'bunny'
require 'connection_manager'

class Commander
  include Celluloid

  def initialize
    Celluloid.logger.info "Initializing Commander"

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.crawler', :direct)
    @q = rf.q('q.poller.commands').bind(@x, :routing_key => 'config')

    listen
  end

  def listen
    @q.subscribe do |delivery_info, properties, payload|
      msg = JSON.parse(payload).symbolize_keys
      dispatch_command(msg)
    end
  end

  def dispatch_command(msg)
    path = SupervisionNode.from_message(message_scope(msg))
    Celluloid.logger.info "Executing #{message_action(msg)} for #{path}"
    Actor[:main].handle_cmd(path, message_action(msg))
  end

  def message_action(msg)
    msg.fetch(:action).to_sym
  end

  def message_scope(msg)
    [msg[:brand], msg[:embed], msg[:service]].unshift('main').compact
  end
end
