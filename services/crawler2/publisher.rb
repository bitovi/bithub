require 'bunny'
require_relative 'digest_set'

class Publisher
  include Celluloid
  include AmqpHelpers

  def initialize
    Celluloid.logger.info "Initializing Publisher"
    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel

    # Exchange and queue
    @x = @chan.topic("x.events", :auto_delete => true)
    @q = @chan.queue("q.events", :auto_delete => true).bind(@x)

    @filter = DigestSet.new
  end

  def publish(brand, events)
    Celluloid.logger.info "-----------> Publishing with routing_key:#{brand}"
    events.each do |e|
      Celluloid.logger.info e.text
    end
    
    # reject_old(brand, process(events)).each do |e|
    #   @x.publish(e, routing_key: brand)
    # end
  end

  def process(events)
    events.map{|e| ResponseProcessor.new(e).extract_raw}
  end

  def reject_old(brand, events)
    @filter.reject_old(brand, events)
  end
end
