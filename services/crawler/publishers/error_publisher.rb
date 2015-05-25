require 'connection_manager'
require 'rabbit_factory'
require 'newrelic_rpm'

class ErrorPublisher
  include Celluloid
  include Celluloid::Logger

  def initialize
    info 'Initializing Error publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)

    @x = rf.x('x.web', :direct)
    @q = rf.q('q.web.errors').bind(@x, routing_key: 'errors')
  end

  def publish(error, owner_data)
    info "[#{owner_data.to_log_format}][ERROR_PUBLISHER] Publishing error #{error.class.name}"
    @x.publish(msg(error, owner_data).to_json, routing_key: 'errors')
  end

  def msg(error, owner_data)
    {
      error: {
        klass: error.class.name,
        message: error.message,
        backtrace: error.backtrace.join("\n"),
        service_id: owner_data.service.id # TODO: remove, already contained in meta
      },
      meta: owner_data.to_h
    }
  end

end
