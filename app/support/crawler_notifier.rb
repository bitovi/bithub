module Support
  class CrawlerNotifier
    include AmqpHelpers
    include Literate

    def notif
      Rails.logger.info "Publishing command #{msg}"
      rabbit(exchange_name: 'x.crawler').publish(msg, :config)
    end
  end
end
