module Support
  class LiveserviceNotifier
    include AmqpHelpers

    def notif(msg, rk)
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.liveservice').publish(msg, rk)
    end
  end
end
