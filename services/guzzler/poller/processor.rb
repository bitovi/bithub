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
          Guzzler.processing_chain.invoke(events, fetch_job).each do |event|
            Guzzler.lpush('event_q', event)
          end
        else
          Guzzler.logger.warn "Don't know how to process job #{job.feed}/#{job.type}"
        end
        @manager.async.processor_done(current_actor)

      rescue Fetchers::FetchError => e
        Guzzler.lpush('error_q', [job_error(fetch_job)])
        @manager.async.processor_done(current_actor)
      end

      def inspect
        "<Processor##{object_id.to_s(16)}>"
      end

      private
      
      def job_error(error, fetch_job)
        {
          data: {
            klass: error.class.name,
            message: error.message,
            backtrace: error.backtrace.join("\n")
            # happened_at: Time.now.to_f
          },
          meta: {
            tenant_name: fetch_job.tenant_name,
            service_id: fetch_job.service_id
          }
        }
      end

      def thread_identity
        @str ||= Thread.current.object_id.to_s(36)
      end

    end
  end
end
