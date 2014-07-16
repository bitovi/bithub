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
      msg = MultiJson.load(payload).symbolize_keys
      dispatch_command(msg)
    end
  end

  def publish(msg, rk)
    @x.publish(MultiJson.dump(msg), :routing_key => rk)
  end

  def dispatch_command(msg)
    Celluloid.logger.info "Executing #{message_action(msg)} for #{message_scope(msg)}"
    Celluloid::Actor[:main_supervisor].reload_brand_feed(*message_scope(msg))
  end

  def message_action(msg)
    msg.fetch(:action)
  end

  def message_scope(msg)
    [msg.fetch(:brand_name), msg.fetch(:feed_name)]
  end
  
  def rabbitmq_uri
    ENV.fetch('RABBITMQ_URI') { "amqp://bithub:Ei7PhaaH@localhost/bithub" }
  end

end
