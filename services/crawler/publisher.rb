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

  def publish(brand, events) # pass in feed?
    Celluloid.logger.info "-----------> Publishing with routing_key: #{brand}"

    events.each do |e|
      # STEPS
      # ------
      # process
      # filter (reject_old)
      # publish
    end
  end

  def process(events)
    # process with ResponseProcessor.new(events, feed).process
    # should return something like
    #
    # {
    #   feed_name: "",
    #   type_name: "",
    #   brand_name: "",
    #   content_digest: "",
    #   source_data: {}
    # }
  end

  def reject_old
    # filter old stuff with DigestSet.reject_old(events)
    # should return only new events
  end

  def send(events, brand)
    events.each do |e|
      @x.publish(e, routing_key: brand)
    end
  end

  def reject_old(brand, events)
    @filter.reject_old(brand, events)
  end
end
