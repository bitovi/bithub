require 'bunny'
require_relative 'digest_set'

class Publisher
  include Celluloid

  def initialize
    @rabbit = Bunny.new
    @rabbit.start
    @chan = @rabbit.create_channel

    # Exchange and queue
    @x = @chan.topic("x.events", :auto_delete => true)
    @q = @chan.queue("q.events", :auto_delete => true).bind(@x)

    @filter = DigestSet.new
  end

  def publish(brand, events)
    Celluloid.logger.info "-----------> Publishing with routing_key: #{brand}"
    events.each do |e|
      #Celluloid.logger.info e.text
      Celluloid.logger.info e.inspect
    end

    # reject_old(brand, process(events)).each do |e|
    #   @x.publish(e, routing_key: brand)
    # end

    # {
    #   feed_name: "",
    #   type_name: "",
    #   content_digest: "",
    #   brand_name: "",
    #   source_data: {}
    # }
  end

  def process(events)
    events.map{|e| ResponseProcessor.new(e).extract_raw}
  end

  def reject_old(brand, events)
    @filter.reject_old(brand, events)
  end
end
