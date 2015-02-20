require 'bunny'
require 'connection_manager'

class CommandHandler
  include Celluloid

  def initialize(receiver_actor_name, opts={})
    Celluloid.logger.info "Initializing Commander"

    @receiver_actor_name = receiver_actor_name
    @logger              = opts[:logger] || Celluloid.logger

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.crawler', :direct)
    @q = rf.q('q.poller.commands').bind(@x, :routing_key => 'config')

    listen
  end

  def listen
    @q.subscribe do |delivery_info, properties, payload|
      msg = JSON.parse(payload).symbolize_keys
      dispatch_command msg
    end
  end

  def dispatch_command(msg)
    if receiver = Actor[@receiver_actor_name]
      receiver.handle_message msg
    else
      @logger.info "Unable to dispatch command #{msg}"
    end
  end

end
