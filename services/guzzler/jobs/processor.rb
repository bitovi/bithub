require 'util'
require 'guzzler/fetchers/mapper'

module Guzzler
  module Jobs

    class Processor
      include Util
      include Celluloid

      attr_accessor :proxy_id

      def initialize(boss)
        @manager = boss
      end

      def process(fetch_job)
        if fetcher = Guzzler::Fetchers::Mapper.new(fetch_job).fetcher
          events = fetcher.fetch
          processed_events = Guzzler.event_chain.invoke(events, fetch_job)
          Guzzler.publish('event_q', processed_events)
        end

        @manager.async.processor_done(current_actor)
      end

      def inspect
        "<Processor##{object_id.to_s(16)}>"
      end

      private

      def thread_identity
        @str ||= Thread.current.object_id.to_s(36)
      end

    end
  end
end
