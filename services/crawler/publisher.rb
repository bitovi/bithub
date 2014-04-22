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

    @x = @chan.direct("x.events")
    @q = @chan.queue("q.events").bind(@x)

    @filter = DigestSet.new
  end

  def publish(brand, feed, events)
    # process events, build event hashes for sending
    processed_events = process(events, brand, feed).compact

    # reject previously sent events
    new_events  = reject_old processed_events

    # finally send events to MQ
    send new_events, brand
  end

  def send(events, brand)
    events.each {|e| send_one e,brand}
  end

  def send_one(event, brand)
    Celluloid.logger.info "(#{event[:content_digest]}) Publishing message!"
    @x.publish MultiJson.dump(event)
  end

  private

  def reject_old(events)
    @filter.reject_old events
  end

  def process(events, brand, feed)
    events.map do |e|
      process_one e, brand, feed
    end
  end

  def process_one(event, brand, feed)
    event     = event.to_h
    feed      = feed.to_s
    brand     = brand.to_s
    processed = nil

    begin
      dispatched = Events::Dispatcher.dispatch(event, feed)
      processed = {
        meta: {
          feed_name: feed,
          type_name: dispatched.type_name.snake_case,
          brand_name: brand,
        },
        content_digest: dispatched.content_digest,
        source_data: event
      }
      Celluloid.logger.debug "(#{processed[:content_digest]}) Event processed: #{processed[:meta].inspect}"

    rescue Events::DispatchError => e
      Celluloid.logger.info "Failed to dispatch event from feed #{feed} for brand #{brand}"
      Celluloid.logger.debug "Failed to dispatch event #{event.inspect}"
    end

    processed
  end

end
