module Guzzler::Listener

  class Registry
    include Celluloid

    class InvalidKeyValuesError < StandardError; end

    SubscriptionKey = Struct.new :feed, :type, :id

    def initialize(opts={})
      @subscriptions = Hash.new {|h,k| h[k]=[]}
    end
    attr_reader :subscriptions

    def subscribe(feed, type, id, service)
      Guzzler.logger.info "Subscribing #{feed} / #{type} for #{service}"

      if feed && type && id
        key = SubscriptionKey.new feed, type, id
        @subscriptions[key].push(service) unless @subscriptions[key].include? service
      else
        nil
      end
    end

    def unsubscribe(feed, type, id, service)
      Guzzler.logger.info "Unsubscribing #{feed} / #{type} for #{service}"

      key = SubscriptionKey.new feed, type, id
      @subscriptions[key].delete service
    end

    def fetch(feed, type, id)
      key = SubscriptionKey.new feed, type, id
      @subscriptions[key]
    end

  end
end
