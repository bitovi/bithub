module Support
  class CrawlerNotifier
    include AmqpHelpers

    def notif(msg)
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.crawler').publish(msg, :config)
    end
  end
end
