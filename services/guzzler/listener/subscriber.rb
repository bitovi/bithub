require 'subscribers/all'
require 'fetchers/all'
require 'guzzler/util'

module Guzzler
  module Listener

    # Subscriber Proxy, delegates subscriptions to concrete classes
    class Subscriber
      include Util
      include Celluloid

      def initialize(registry, condvar)
        @registry = registry
        @unsubscribed = condvar

        @subscriptions = []

        Guzzler.logger.info "Fetching listening services"
        Guzzler.services(:listening).each do |sk|
          service = Guzzler::Service.new(sk, sc = Guzzler.service_config(sk))
          @subscriptions << subscriber_class(service).new(@registry, service)
        end
      end

      def subscribe
        @subscriptions.each { |s| handle_subscription_errors(s, :subscribe) }
      end

      def unsubscribe
        @subscriptions.each { |s| handle_subscription_errors(s, :unsubscribe) }
        Guzzler.logger.info "Unsubscribed all services"
        @unsubscribed.signal
      end

      def preload_items
        @subscriptions.each { |s| handle_preloading_results_and_errors(s) }
      end

      def handle_preloading_results_and_errors(s)
        return unless s.respond_to? :preload_items

        if (events = s.preload_items).empty?
          Guzzler.notifier.empty_response_fetched(s.service)
        else
          Guzzler.processing_chain.invoke(events, s.service).each do |event|
            Guzzler.enq('event_q', event)
          end
        end
      rescue Guzzler::FetchError => e
        Guzzler.enq('error_q', [ Guzzler::ServiceError.new(e, s.service).to_h ])
      end

      def handle_subscription_errors(s, method)
        s.send(method)
      rescue Guzzler::SubscriptionError => e
        Guzzler.enq('error_q', [ Guzzler::ServiceError.new(e, s.service).to_h ])
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
