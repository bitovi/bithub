module Support

  class CrawlerNotifier
    include Literate

    def notif
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.crawler').publish(msg, :config)
    end
  
    def rabbit(args = {})
      @conn = Bunny.new(rabbitmq_uri).start
      ch = @conn.create_channel

      exchange_type = args.fetch(:exchange_type) { 'direct' }
      exchange_name = args.fetch(:exchange_name) { '' }
      exchange_opts = args.fetch(:exchange_opts) { Hash.new }

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

  end
end
