require 'amqp_helpers'

class LiveserviceNotifier
  include AmqpHelpers

  def notif(msg, rk)
    rabbit(exchange_name: 'x.liveservice', exchange_opts: {auto_delete: true}).publish(msg, rk)
  end
end
