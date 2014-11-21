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

  def publish(owner_data, events, opts={})
    decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    # reject previously sent events
    new_events = processed events, owner_data, decorator
    new_events = reject_old new_events if @reject_old == true

    # finally send events to MQ
    send new_events, owner_data.brand
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

  def processed(events, owner_data, decorator)
    events.map do |e|
      process_one e, owner_data, decorator
    end.compact
  end

  def process_one(event, owner_data, decorator)
    event     = event.to_h
    brand     = owner_data.brand_name
    embed     = owner_data.embed_name
    feed      = owner_data.service_feed
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
      Celluloid.logger.error e
    end

    decorator.decorate processed
  end

end
