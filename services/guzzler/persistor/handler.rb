require 'worker'
require 'error'

module Guzzler::Persistor

  class Handler < Guzzler::Worker
    
    def name_for_logs
      self.class.name.gsub(/.*::/, '')
    end

    def handle_errors
      yield

    rescue Events::DeterminationError => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e.message} | #{e.context}"
      raise Guzzler::EventHandlingError.new(e)
    rescue Events::OrphanedEventError => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e}"
      raise Guzzler::EventHandlingError.new(e)
    rescue Events::BuildingError => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e}"
      raise Guzzler::EventHandlingError.new(e)

    rescue Entities::DeterminationError => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e} | #{e.context}"
      raise Guzzler::EntityHandlingError.new(e)
    rescue Entities::NormalizationError => e
      Guzzler.logger.error "[#{name_for_logs}] #{e.class.name} | #{e.message} | missing tags: #{e.context.join(',')}"
      raise Guzzler::EntityHandlingError.new(e)
    rescue Entities::UpdatingError => e
      Guzzler.logger.error "[#{name_for_logs}] #{e.class.name} | #{e.message} | updating: #{e.context.inspect}"
      raise Guzzler::EntityHandlingError.new(e)

    rescue ActiveRecord::RecordNotFound => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e}"
      raise Guzzler::HandlingError.new(e)
    rescue ActiveRecord::RecordInvalid => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e}"
      raise Guzzler::HandlingError.new(e)
    rescue ActiveRecord::RecordNotUnique => e
      Guzzler.logger.warn "[#{name_for_logs}] #{e.class.name} | #{e}"
      raise Guzzler::HandlingError.new(e)

    rescue => e
      Guzzler.logger.error "[#{name_for_logs}] #{e.class.name} | #{e}"
    ensure
      Apartment::Tenant.switch!
    end
  end
end
