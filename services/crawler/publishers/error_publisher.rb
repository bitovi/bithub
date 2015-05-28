require 'connection_manager'
require 'rabbit_factory'

class ErrorPublisher
  include Celluloid
  include Celluloid::Logger

  def initialize
    info 'Initializing Error publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)

    @x = rf.x('x.web', :direct)
    @q = rf.q('q.web.errors').bind(@x, routing_key: 'errors')

    every(5) do
      info "ErrorPublisher mailbox size #{Actor.current.mailbox.size}"
    end
  end

  def publish(error, owner_info)
    info "#{owner_info.to_log_format} Publishing Error #{error.class.name}"
    @x.publish(msg(error, owner_info).to_json, routing_key: 'errors')
  end

  def msg(error, owner_info)
    {
      error: {
        klass: error.class.name,
        message: error.message,
        backtrace: error.backtrace.join("\n"),
        service_id: owner_info.service.id # TODO: remove, already contained in meta
      },
      meta: {
        type_name: owner_info.service.type_name,
        brand_id: owner_info.brand.id,
        embed_id: owner_info.embed.id,
        service_id: owner_info.service.id,
        brand_name: owner_info.brand.name,
        embed_name: owner_info.embed.name,
        feed_name: owner_info.service.feed_name
      }
    }
  end

end
