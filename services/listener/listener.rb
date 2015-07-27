class Listener
  include Celluloid
  include Celluloid::Logger

  def initialize(q_name, q_routing_key, handler_class)
    rf = RabbitHelper.new(ConnectionManager.instance.rabbit)
    @c = rf.chan
    @x = rf.x('x.web')
    @q = rf.q(q_name).bind(@x, routing_key: q_routing_key)

    @handler = handler_class.new(self)

    info "[#{@handler.name_for_logs}] Connected to AMQP, queue name: #{q_name}"

    every(Intervals::ACTOR_MAILBOX_REPORT) do
      info "[#{@handler.name_for_logs}] Mailbox size #{Actor.current.mailbox.size}"
    end

    async.listen
  end
  attr_reader :x, :q

  def listen
    @q.subscribe(manual_ack: true, block: false) do |delivery_info, properties, payload|
      packet = JSON.parse payload
      @handler.handle packet
      @c.acknowledge delivery_info.delivery_tag, false
    end
  end

  def handle_errors
    yield
  rescue => err
    error "[#{@handler.name_for_logs}] #{err}"
  ensure
    Apartment::Tenant.switch! # either way switch back to public
  end
end
