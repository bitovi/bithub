require 'andand'
require 'core_ext'
require 'core_helpers'
require 'loggable'

require_relative 'events/dispatcher'
require_relative 'entities/dispatcher'

class Dispatcher
  include Loggable

  def initialize
    initialize_logger("DEBUG")
  end

  def dispatch(response, hint=nil)
    event = Events::Dispatcher.dispatch(response, hint)
    entity = Entities::Dispatcher.dispatch(event)

    @logger.debug "MAPPING: #{event.class.name} -> #{entity.class.name}"
    
    return nil if event.nil? || entity.nil?

    begin
      ActiveRecord::Base.transaction do
        event.build.persist!
        entity.procure.update_if_found.determine.group.normalize.persist!
      end

    rescue Events::InvalidDigestSeed => err
      @logger.error "#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name} | #{err.message} | #{err.source_data}"
    rescue Entities::Protocol::MissingCriticalTags => err
      @logger.error "#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name} | #{err.message} | #{err.tags}"
    rescue ActiveRecord::RecordInvalid => err
      @logger.error "#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name} | #{err.message}"
    end

    [event.instance, entity.instance]
  end
end
