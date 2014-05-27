require 'multi_json'

module AmqpHelpers

  def rabbit(args = {})
    @conn = Bunny.new(rabbitmq_uri).start
    ch = @conn.create_channel

    exchange_type = args.fetch(:exchange_type) { 'direct' }
    exchange_name = args.fetch(:exchange_name) { '' }
    exchange_opts = args.fetch(:exchange_opts) { {:auto_delete => true, :durable => false} }

    @x = ch.send(exchange_type, *[exchange_name, exchange_opts])
    self
  end

  def publish(msg, rk)
    returning @x.publish(MultiJson.dump(msg), :routing_key => rk) do
      @conn.close
    end
  end

  def exchange
    @x
  end

  def rabbitmq_uri
    ENV.fetch('RABBITMQ_URI') { "amqp://bithub:Ei7PhaaH@localhost/bithub" }
  end

  def returning(exp)
    yield
    exp
  end
end
