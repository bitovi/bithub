require 'events/events'

require 'persistent/digest_set'
require 'connection_manager'
require 'rabbit_helper'

class EventPublisher
  include Celluloid
  include Celluloid::Logger

  def initialize(opts={})
    info '[EVENT_PUBLISHER] Initializing...'

    @reject_old = opts.fetch(:reject_old) { true }
    @filter = DigestSet.new

    rf = RabbitHelper.new(ConnectionManager.instance.rabbit)
    @x = rf.x('x.web')
    @q = rf.q('q.web.events').bind(@x, routing_key: 'events')

    info '[EVENT_PUBLISHER] Waiting for events to publish.'
  end

  def publish(events, owner_data, opts={})
    decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    # reject previously sent events
    new_events = processed events, owner_data, decorator
    new_events = reject_old new_events if @reject_old == true

    info "[EVENT_PUBLISHER][#{owner_data.to_log_format}] Published #{new_events.size} new events out of fetched #{events.size}"

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

    dispatched = Events.event_instance({
      source_data: event
    }, feed)

    processed = {
      meta: owner_data.to_h,
      content_digest: dispatched.content_digest,
      source_data: event
    }

    decorator.decorate processed
  rescue Events::DeterminationError => e
    error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e}"
    nil
  rescue KeyError => e
    error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e}"
    nil # if we can't dispatch, return nil so it will end up filtered out
  rescue TypeError => e
    error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e} | #{event.inspect}"
    raise e
  end
end
