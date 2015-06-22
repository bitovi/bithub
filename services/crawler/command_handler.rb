require 'bunny'
require 'connection_manager'
require 'services/intervals'

class CommandHandler
  include Celluloid
  include Celluloid::Logger

  def initialize(opts={})
    @consumer_name = opts.fetch(:consumer_name)
    @receiver_name = opts.fetch(:receiver_name) { :main }

    rf = RabbitHelper.new(@chan = ConnectionManager.instance.rabbit)
    @x = rf.x('x.crawler', :direct)
    @q = rf.q("q.crawler.#{@consumer_name}.commands").bind(@x, :routing_key => 'config')

    wait_for_receiver
  end

  def wait_for_receiver
    if receiver && receiver.booted?
      @q.purge # Main supervisor just booted, so we have a fresh state of the world.
      listen
    else
      after(Intervals::CommandHandler::RETRY) { wait_for_receiver }
    end
  end

  def cancel_consumer_and_wait
    info "[COMMAND_HANDLER] Unsubscribing, waiting for receiver '#{shard_name}'"
    @consumer.cancel
    wait_for_receiver
  end

  def listen
    info "[COMMAND_HANDLER] Listening for commands"
    @consumer = @q.subscribe do |delivery_info, properties, payload|
      msg = JSON.parse(payload).symbolize_keys

      if receiver && receiver.booted?
        receiver.handle_msg(msg)
      else
        cancel_consumer_and_wait
      end
    end
  end

  def shard_name
    "#{@consumer_name}>#{@receiver_name}"
  end

  def receiver
    Actor[@receiver_name]
  end
end
