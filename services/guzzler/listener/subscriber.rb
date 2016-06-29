require 'subscribers/all'
require 'fetchers/all'
require 'guzzler/util'

module Guzzler
  module Listener

    # Subscriber Proxy, delegates subscriptions to concrete classes
    class Subscriber
      include Util
      include Celluloid

      def initialize(registry, http_server)
        @registry = registry
        @http_server = http_server
        every(60) { refresh }
      end

      def start
        if @http_server.started?
          Listener::Subscribers::FacebookAppSubscriber.subscribe
        else
          Guzzler.logger.info "Waiting on HttpServer to bind."
          after(1) { start }
          return
        end
        
        Guzzler.logger.info "Subscribing all services."

        Guzzler.smembers('services:listening').each do |sk|
          begin
            service = Guzzler::Service.new(sk, sc = Guzzler.service_config(sk))
            manage_subscription(service, :subscribe)
          rescue => e
            Guzzler.lpush('error_q', [ sk ])
          end
        end
      end

      def stop
        Guzzler.logger.info "Unsubscribing all services"
        Guzzler.smembers('services:listening:subscribed').each do |sk|
          service = Guzzler::Service.new(sk, sc = Guzzler.service_config(sk))
          manage_subscription(service, :unsubscribe)
        end
        @unsubscribed.signal
      end
      
      def refresh
        Guzzler.sdiff('services:listening', 'services:listening:subscribed').each do |sk|
          begin
            service = Guzzler::Service.new(sk, sc = Guzzler.service_config(sk))
            Guzzler.logger.info "New service: #{service}. Subscribing ..."
            manage_subscription(service, :subscribe)
          rescue => e
            Guzzler.lpush('error_q', [ sk ])
          end
        end
      end

      def manage_subscription(service, method)
        subscriber = subscriber_class(service).new(@registry, service)

        if method == :subscribe
          subscriber.subscribe
          preload_items(subscriber) if subscriber.respond_to? :preload_items
          Guzzler.sadd('services:listening:subscribed', service.member)
        elsif method == :unsubscribe
          subscriber.unsubscribe
          Guzzler.srem('services:listening:subscribed', service.member)
        end

      rescue Guzzler::SubscriptionError => e
        Guzzler.lpush('error_q', [ Guzzler::ServiceError.new(e, service).to_h ])
        Guzzler.logger.error e.message
      end
      
      def preload_items(subscriber)
        if (events = subscriber.preload_items).empty?
          Guzzler.notifier.empty_response_fetched(subscriber.service)
        else
          Guzzler.processing_chain.invoke(events, subscriber.service).each do |event|
            Guzzler.lpush('event_q', event)
          end
        end
      rescue => e
        Guzzler.lpush('error_q', [ ServiceError.new(e, subscriber.service).to_h ])
      end

      def subscriber_class(service)
        if service.feed_name == 'instagram'
          Guzzler::Listener::Subscribers::InstagramTag
        elsif service.feed_name == 'facebook'
          Guzzler::Listener::Subscribers::FacebookPage
        elsif service.feed_name == 'foursquare'
          Guzzler::Listener::Subscribers::FoursquareVenue
        else
          Guzzler::Listener::Subscribers::NullSubscriber
        end
      end
    end
  end
end
