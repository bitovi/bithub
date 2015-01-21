class RabbitFactory
  def initialize(rabbit_channel)
    @chan = rabbit_channel
  end

  def x(name, type, opts = {})
    @chan.exchange(name, defaults.merge(opts).merge({type: type}))
  end

  def q(name, opts = {})
    @chan.queue(name, defaults.merge(opts))
  end

  def defaults
    { durable: false, auto_delete: true }
  end
end
