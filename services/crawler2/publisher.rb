require 'bunny'

class Publisher
  include Celluloid

  def initialize
    @conn = Bunny.new
    @conn.start
    @chan = @conn.create_channel

    # Exchange and queue
    @x = @chan.topic("x.events", :auto_delete => true)
    @q = @chan.queue("q.events", :auto_delete => true).bind(@x)
  end

  def publish(msg, routing_key = nil)
    @x.publish(msg, routing_key: routing_key)
  end
end
