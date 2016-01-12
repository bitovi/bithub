require 'util'
require 'fetchers/mapper'

module Guzzler
  module Jobs

    class Processor
      include Util
      include Celluloid

      attr_accessor :proxy_id

      def initialize(boss)
        @manager = boss
      end

      def process(service)
        if fetcher = Guzzler::Fetchers::Mapper.new(service).fetcher
          events = fetcher.fetch
          Guzzler.processing_chain.invoke(events, service).each do |event|
            Guzzler.lpush('event_q', event)
          end
        else
          Guzzler.logger.warn "Don't know how to process job #{job.feed}/#{job.type}"
        end
        @manager.async.processor_done(current_actor)

      rescue Fetchers::FetchError => e
        Guzzler.lpush('error_q', [ ServiceError.new(e, service).to_h ])
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
