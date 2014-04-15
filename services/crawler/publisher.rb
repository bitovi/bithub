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

  def publish(brand, feed, events)
    Celluloid.logger.info "-----------> Publishing from #{feed} with routing_key: #{brand}"
    processed_events = events.map {|e| process e, brand, feed}.compact
    new_events  = reject_old processed_events, brand
    send new_events, brand
  end

  def process(event, brand, feed)
    event = event.to_hash
    feed  = feed.to_s
    brand = brand.to_s

    begin
      dispatched = Events::Dispatcher.dispatch(event, feed)
      {
        feed_name: feed, #dispatched.feed_name.snake_case,
        type_name: dispatched.type_name.snake_case,
        brand_name: brand,
        content_digest: dispatched.content_digest,
        source_data: event
      }
    rescue Events::DispatchError => e
      Celluloid.logger.info "Failed to dispatch event from #{feed}"
      nil
    end
  end

  def reject_old(events, brand)
    @filter.reject_old events, brand
  end

  def send(events, brand)
    events.each {|e| send_one e,brand}
  end

  def send_one(event, brand)
    #@x.publish(MultiJson.dump(event), routing_key: brand)
    @x.publish MultiJson.dump(event)
  end

end
