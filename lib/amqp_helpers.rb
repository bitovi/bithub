require 'yajl'

module AmqpHelpers

  class MissingMessageException < Exception; end

  def self.publish_to_mq(args)
    raise MissingMessageException unless msg = args[:msg]

    exchange_name = args[:exchange_name] || ''
    exchange_type = args[:exchange_type]

    conn = Bunny.new(ENV['RABBITMQ_URI'])
    conn.start

    ch = conn.create_channel

    if ['fanout', 'direct'].include?(exchange_type) and exchange_name.length > 0
      x = ch.send(exchange_type, exchange_name)
    else
      x = ch.default_exchange
    end

    x.publish(Yajl::Encoder.encode(msg))

    conn.close
  end

end
