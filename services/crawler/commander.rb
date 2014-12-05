require 'bunny'
require 'amqp_helpers'

class Commander
  include Celluloid

  def initialize
    Celluloid.logger.info "Initializing Commander"
    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel
    @x = @chan.direct("x.crawler")
    listen
  end

  def listen
    @q = @chan\
      .queue("q.poller.notifications", :auto_delete => true)\
      .bind(@x, :routing_key => "config")

    @q.subscribe do |delivery_info, properties, payload|
      msg = JSON.parse(payload).symbolize_keys
      dispatch_command(msg)
    end
  end

  def publish(msg, rk)
    @x.publish(msg.to_json, :routing_key => rk)
  end

  def dispatch_command(msg)
    path = TreePath.from_message(message_scope(msg))

    Celluloid.logger.info "Executing #{message_action(msg)} for #{path}"
    Celluloid::Actor[:main].handle_cmd(path, message_action(msg))
  end

  def message_action(msg)
    msg.fetch(:action).to_sym
  end

  def message_scope(msg)
    [
      'main',
      msg[:brand_name],
      msg[:embed_name],
      msg[:service_info],
    ].compact
  end

  def rabbitmq_uri
    ENV.fetch('RABBITMQ_URI') { "amqp://bithub:Ei7PhaaH@localhost/%2Fbithub" }
  end

end
