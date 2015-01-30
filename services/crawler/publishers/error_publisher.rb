require 'connection_manager'
require 'rabbit_factory'

class ErrorPublisher
  include Celluloid

  def initialize
    Celluloid.logger.info 'Initializing error publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)

    @x = rf.x('x.web', :direct)
    @q = rf.q('q.web.errors').bind(@x, routing_key: 'errors')
  end

  def publish(error, owner_info)
    @x.publish(msg(error, owner_info).to_json, routing_key: 'errors')
  end

  def msg(error)
    {
      payload: {
        klass: error.class.name,
        message: error.message,
        service_id: owner_info.service.id
      },
      meta: {
        brand_name: owner_info.brand.name,
      }
    }
  end
end
