require 'worker'
require 'fetchers/mapper'
require 'messages'

module Guzzler::Poller

  class Processor < Guzzler::Worker

    def process(service)
      if fetcher = Guzzler::Fetchers::Mapper.new(service).fetcher
        if events = fetcher.fetch
          Guzzler.processing_chain.invoke(events, service).each do |event|
            Guzzler.lpush('event_q', event)
          end
        else

          Guzzler.logger.debug "_____________________________"

          Guzzler.lpush('liveservice:services', { 
            meta: { tenant_name: service.tenant_name, embed_id: service.embed_id },
            payload: { 
              service: { id: service.id, empty_results: true }
            }
          })
          
        end
      else
        Guzzler.logger.warn "Don't know how to process job #{job.feed}/#{job.type}"
      end

      @manager.async.worker_done(current_actor)
    rescue Guzzler::FetchError => e
      Guzzler.lpush('error_q', [ ServiceError.new(e, service).to_h ])
      @manager.async.worker_done(current_actor)
    end

  end
end
