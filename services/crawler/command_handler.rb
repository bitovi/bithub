require 'bunny'
require 'connection_manager'

class CommandHandler
  include Celluloid
  include Celluloid::Logger

  def initialize(opts={})
    @receiver_name = opts.fetch(:receiver_name) { :main }

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.crawler', :direct)
    @q = rf.q('q.poller.commands').bind(@x, :routing_key => 'config')

    listen
  end

  def listen
    info "Initializing Commander"
    @q.subscribe do |delivery_info, properties, payload|
      msg = JSON.parse(payload).symbolize_keys
      dispatch_command msg
    end
  end

  def dispatch_command(msg)
    if receiver
      receiver.handle_message msg
    else
      error "Unable to dispatch command #{msg}"
    end
  end

  def receiver
    Actor[@receiver_name]
  end
end
