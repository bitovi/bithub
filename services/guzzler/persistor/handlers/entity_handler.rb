require 'handler'

module Guzzler::Handlers
  class EntityHandler < Guzzler::Handler

    def handle(raw_data)
      super do |packet|
        tenant_name = packet.fetch('tenant_name')
        event_id = packet.fetch('event_id')

        handle_errors do
          Apartment::Tenant.switch(tenant_name) do
            event = Event.find(event_id)
            if event.is_processed
              warn "[#{name_for_logs}] Event already processed"
            else
              run_pipeline_with_benchmarks(event)
            end
          end
        end
      end

      @popper.ready
    end
    
    def run_pipeline_with_benchmarks(event)
      entity = Entities.entity_instance(event.wrapped)

      entity_processing_time = Benchmark.measure do
        entity.procure.update_if_found.group.normalize.persist!.route
      end
      
      event.update_attribute(:is_processed, true)

      Guzzler.logger.info "[#{name_for_logs}][#{entity.repr_for_logs}] processed in #{entity_processing_time}"
      entity

    ensure
      event.update_attribute(:was_viewed, true)
    end

    def handle_errors
      yield
    rescue ActiveRecord::RecordNotFound => e
      Guzzler.logger.error "[#{name_for_logs}] #{e}"
      nil
    rescue ActiveRecord::RecordInvalid => e
      Guzzler.logger.error "[#{name_for_logs}] #{e}"
      nil
    rescue Entities::DeterminationError => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e} | #{e.context}"
      nil
    rescue Entities::NormalizationError => e
      Guzzler.logger.error "[#{name_for_logs}] #{e.message} | missing tags: #{e.context.join(',')}"
      nil
    rescue Entities::UpdatingError => e
      Guzzler.logger.error "[#{name_for_logs}] #{e.message} | updating: #{e.context.inspect}"
      nil
    ensure
      Apartment::Tenant.switch!
    end

  end
end
