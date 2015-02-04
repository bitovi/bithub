require 'connection_manager'
require 'rabbit_factory'

class ErrorPublisher
  include Celluloid

  def initialize
    Celluloid.logger.info 'Initializing Error publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)

    @x = rf.x('x.web', :direct)
    @q = rf.q('q.web.errors').bind(@x, routing_key: 'errors')
  end

  def publish(error, owner_info)
    Celluloid.logger.info "Publishing Error | #{error.class.name}"
    @x.publish(msg(error, owner_info).to_json, routing_key: 'errors')
  end

  def msg(error, owner_info)
    {
      error: {
        klass: error.class.name,
        message: error.message,
        backtrace: error.backtrace.join("\n"),
        service_id: owner_info.service.id
      },
      meta: {
        brand_name: owner_info.brand.name,
        embed_name: owner_info.embed.name
      }
    }
  end
end
