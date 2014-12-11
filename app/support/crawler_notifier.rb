module Support

  class CrawlerNotifier
    include AmqpHelpers

    def notif(msg)
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.crawler').publish(msg, :config)
    end
  end

  class LiveserviceNotifier
    include AmqpHelpers

    def notif(msg, rk)
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.liveservice').publish(msg, rk)
    end
  end
end
