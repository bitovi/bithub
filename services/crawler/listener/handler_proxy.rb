require 'supervisors/support/owner_data'

class HandlerProxy
  include Celluloid

  attr_reader :handler

  def initialize(publisher_name, logger, configurator_name, handler_class)
    @publisher_name    = publisher_name
    @logger            = logger
    @configurator_name = configurator_name
    @handler           = handler_class.new self

    @logger.info "Started HTTP handler for #{handler_class} on url #{handler_class.path}"
  end

  def handle(req)
    @handler.handle req
  end

  def config
    Actor[@configurator_name].config
  end

  def publish(events, owner_data)
    Actor[@publisher_name].publish events, owner_data
  end

end
