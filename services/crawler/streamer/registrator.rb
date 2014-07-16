require 'bunny'
require 'amqp_helpers'

class Registrator
  include Celluloid

  def initialize
    Celluloid.logger.info "Initializing Registrator"
    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel
    @x = @chan.direct("x.crawler")
    listen
  end

  def listen
    @q_config = @chan\
      .queue("q.streamer.registrations", :auto_delete => true)\
      .bind(@x, :routing_key => "registration")

    @q_config.subscribe do |delivery_info, properties, payload|
      msg = MultiJson.load(payload).symbolize_keys
      send("dispatch_#{message_action(msg)}".to_sym, msg)
    end
  end

  def dispatch_register(msg)
    Celluloid::Actor[:twitter_public_stream].register(
      Channel.new(
        msg.fetch(:brand_name),
        msg.fetch(:terms)
      ),
      reloading: msg.fetch(:reloading) { false }
    )
  end

  def dispatch_unregister(msg)
    Celluloid::Actor[:twitter_public_stream].unregister(
      msg.fetch(:brand_name),
      reloading: msg.fetch(:reloading) { false }
    )
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
