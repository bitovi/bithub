require 'connection_manager'
require 'rabbit_factory'

class NotificationPublisher
  include Celluloid

  def initialize
    Celluloid.logger.info 'Initializing Notification publisher'

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.liveservice', :direct)
    @q = rf.q('q.liveservice.services').bind(@x, routing_key: 'services')
  end

  def publish(notif)
    @x.publish(notif.to_json, routing_key: 'services')
  end
end
