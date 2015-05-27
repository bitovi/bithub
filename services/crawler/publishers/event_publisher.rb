require 'persistent/digest_set'
require 'connection_manager'
require 'rabbit_factory'

class EventPublisher
  include Celluloid
  include Celluloid::Logger

  def initialize(opts={})
    info 'Initializing Entity publisher'

    @reject_old = opts.fetch(:reject_old) { true }
    @filter = DigestSet.new

    rf = RabbitFactory.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.web')
    @q = rf.q('q.web.events').bind(@x, routing_key: 'events')
  end

  def publish(events, owner_data, opts={})
    decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    # reject previously sent events
    new_events = processed events, owner_data, decorator
    new_events = reject_old new_events if @reject_old == true

    info "#{owner_data.to_log_format} Published #{new_events.size} new events out of total #{events.size}"

    new_events.each do |e|
      @x.publish(e.to_json, routing_key: 'events')
    end
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
    feed      = owner_data.service.feed_name
    processed = nil

    dispatched = Events::Dispatcher.dispatch(event, feed)

    processed = {
      meta: {
        type_name: dispatched.type_name.snake_case,
        brand_id: owner_data.brand.id,
        embed_id: owner_data.embed.id,
        service_id: owner_data.service.id,
        brand_name: owner_data.brand.name,
        embed_name: owner_data.embed.name,
        feed_name: feed
      },
      content_digest: dispatched.content_digest,
      source_data: event
    }

    decorator.decorate processed
  rescue Events::DispatchError => e
    error "#{owner_data.to_log_format} #{e}"
    nil # if we can't dispatch, return nil so it will end up filtered out
  end
end
