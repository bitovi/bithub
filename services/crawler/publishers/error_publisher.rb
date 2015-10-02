require 'connection_manager'
require 'rabbit_helper'

class ErrorPublisher
  include Celluloid
  include Celluloid::Logger

  def initialize
    info '[ERROR_PUBLISHER] Initializing...'

    rf = RabbitHelper.new(ConnectionManager.instance.rabbit)

    @x = rf.x('x.web', :direct)
    @q = rf.q('q.web.errors').bind(@x, routing_key: 'errors')

    info '[ERROR_PUBLISHER] Waiting for errors to publish.'
  end

  def publish(error, owner_data)
    info "[ERROR_PUBLISHER][#{owner_data.to_log_format}] Publishing error #{error.class.name}"
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
