require 'andand'
require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require 'events/payload'

require 'entities/mappings'
require 'entities/procurer'
require 'entities/determinator'
require 'entities/grouper'
require 'entities/normalizer'

class Dispatcher
  include Loggable

  def initialize(response)
    initialize_logger("DEBUG")

    # if response.is_a? Events::Payload
    #   @payload = response
    # else
      @payload = Events::Payload.new(response)
    # end
  end

  def dispatch
    new_event = Event.new({
      feed: @payload.feed,
      type: @payload.type,
      content_digest: @payload.content_digest,
      source_data: @payload.source_data,
    })

    @logger.info "Payload FEED::TYPE => #{@payload.feed}::#{@payload.type}"

    entity = Entities::Procurer.new(@payload).procure

    @logger.debug "================================ DETERMIN:"
    @logger.debug entity.inspect

    Entities::Determinator.new(entity).determine
    Entities::Normalizer.new(entity).normalize
    Entities::Grouper.new(entity).group

    # @logger.debug "================================ FINALY:"
    # @logger.debug entity.inspect

    # ActiveRecord::Base.transaction do
    #   new_event.save!
    #   new_entity.save!
    #   parent.save!
    #   children.each {|e| e.save!}
    #   references.each {|e| e.save!}
    # end
  end
end
