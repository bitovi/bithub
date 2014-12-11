module Support
  class LiveserviceNotifier
    include AmqpHelpers

    def notif(msg, rk)
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.liveservice', exchange_opts: {auto_delete: true}).publish(msg, rk)
    end
  end
end
