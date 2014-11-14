require 'bunny'
require_relative 'persistent/digest_set'

class Publisher
  include Celluloid
  include AmqpHelpers

  def initialize(opts={})
    Celluloid.logger.info "Initializing Publisher"

    @reject_old = opts.fetch(:reject_old) { true }

    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel

    @x = @chan.direct("x.events")
    @q = @chan.queue("q.events").bind(@x)

    @filter = DigestSet.new
  end

  def publish(brand, embed, feed, events, opts={})
    decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    # reject previously sent events
    new_events = processed events, brand, embed, feed, decorator
    new_events = reject_old new_events if @reject_old == true

    # finally send events to MQ
    send new_events, brand
  end

  def send(events, brand)
    Celluloid.logger.info "Publishing #{events.size} messages!"
    events.each {|e| send_one e, brand}
  end

  def send_one(event, brand)
    @x.publish event.to_json
  end

  private

  def reject_old(events)
    @filter.reject_old events
  end

  def processed(events, brand, embed, feed, decorator)
    events.map do |e|
      process_one e, brand, embed, feed, decorator
    end.compact
  end

  def process_one(event, brand, embed, feed, decorator)
    event     = event.to_h
    feed      = feed.to_s
    brand     = brand.to_s
    embed     =  embed.to_s
    processed = nil

    begin
      dispatched = Events::Dispatcher.dispatch(event, feed)

      # todo: move this to separete decorator?
      processed = {
        meta: {
          feed_name: feed,
          type_name: dispatched.type_name.snake_case,
          brand_name: brand,
          embed_name: embed
        },
        content_digest: dispatched.content_digest,
        source_data: event
      }

      Celluloid.logger.debug "(#{processed[:content_digest]}) Event processed: #{processed[:meta].inspect}"

    rescue Events::DispatchError => e
      Celluloid.logger.info "Failed to dispatch event from feed #{feed} for brand #{brand}"
      Celluloid.logger.debug "Failed to dispatch event #{event.inspect}"
    end

    decorator.decorate processed
  end

end
