require 'bunny'

class RabbitHelper

  module Sugar
    def x(x_name, chan_is_short_lived = false)
      if is_short_lived & block_given?
        ::ConnectionManager.instance.short_lived_rabbit do |chan|
          yield RabbitHelper.new(chan).x(x_name)
        end
      else
        @x ||= RabbitHelper.new(ConnectionManager.instance.rabbit).x(x_name)
      end
    end

    def q(q_name)
      @q ||= RabbitHelper.new(ConnectionManager.instance.rabbit).q(q_name)
    end
  end

  attr_reader :chan

  def initialize(rabbit_channel)
    @chan = rabbit_channel
  end

  def x(name, type = :direct, opts = {})
    @chan.exchange(name, defaults.merge(opts).merge({type: type}))
  end

  def q(name, opts = {})
    @chan.queue(name, defaults.merge(opts))
  end

  def defaults
    { durable: false, auto_delete: false }
  end
end
