class HandlerProxy
  include Celluloid

  attr_reader :handler

  def initialize(handler_class, opts={})
    @event_publisher_name = opts.fetch(:event_publisher_name) { :event_publisher }
    @error_publisher_name = opts.fetch(:error_publisher_name) { :error_publisher }
    @configurator_name    = opts.fetch(:configurator_name) { :configurator }
    @registry_name        = opts.fetch(:subscription_registry_name) { :subscription_registry }
    @handler              = handler_class.new self, opts

    Celluloid.logger.info "Started HTTP handler for #{handler_class} on url #{handler_class.route}"
  end

  def handle(req)
    @handler.handle req
  end

  def registry
    Actor[@registry_name]
  end

  def publish(events, owner_data)
    Actor[@event_publisher_name].publish events, owner_data
  end

  def publish_error(error, owner_info)
    Actor[@error_publisher_name].publish error, owner_info
  end
end
